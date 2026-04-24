package com.nolumia.plainpad

import android.app.Activity
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.provider.OpenableColumns
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.BufferedReader
import java.io.InputStreamReader
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/**
 * Hosts the SAF (Storage Access Framework) bridge.
 *
 * Flutter is responsible for UI only — all file access goes through Android's
 * Storage Access Framework so the app never touches raw filesystem paths.
 * Users pick documents via [Intent.ACTION_OPEN_DOCUMENT] /
 * [Intent.ACTION_CREATE_DOCUMENT] and the resulting `content://` URIs are
 * read/written as UTF-8 streams.
 *
 * Read and write stream the entire document on a background executor so
 * large files do not block the main thread (and so SAF latency to remote
 * providers like Drive/Nextcloud does not stall the UI or risk ANR). The
 * MethodChannel result is always delivered back on the main thread.
 */
class MainActivity : FlutterActivity() {

    private var pendingResult: MethodChannel.Result? = null

    /**
     * Single-threaded executor dedicated to SAF I/O. One file op at a time
     * is sufficient for a text editor and keeps request ordering obvious.
     */
    private val ioExecutor: ExecutorService = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "pickDocument" -> pickDocument(result)
                "createDocument" -> {
                    val suggestedName = call.argument<String>("suggestedName") ?: "untitled.txt"
                    val mimeType = call.argument<String>("mimeType") ?: "text/plain"
                    createDocument(suggestedName, mimeType, result)
                }
                "readDocument" -> {
                    val uri = call.argument<String>("uri")
                    if (uri == null) {
                        result.error("invalid_arguments", "uri is required", null)
                    } else {
                        readDocument(uri, result)
                    }
                }
                "writeDocument" -> {
                    val uri = call.argument<String>("uri")
                    val content = call.argument<String>("content")
                    if (uri == null || content == null) {
                        result.error("invalid_arguments", "uri and content are required", null)
                    } else {
                        writeDocument(uri, content, result)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        ioExecutor.shutdown()
        super.onDestroy()
    }

    private fun pickDocument(result: MethodChannel.Result) {
        if (pendingResult != null) {
            result.error("busy", "Another document picker is already active", null)
            return
        }
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = "*/*"
            putExtra(
                Intent.EXTRA_MIME_TYPES,
                arrayOf(
                    "text/*",
                    "application/json",
                    "application/xml",
                    "application/x-yaml",
                    "application/octet-stream",
                ),
            )
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }
        pendingResult = result
        startActivityForResult(intent, REQUEST_OPEN)
    }

    private fun createDocument(
        suggestedName: String,
        mimeType: String,
        result: MethodChannel.Result,
    ) {
        if (pendingResult != null) {
            result.error("busy", "Another document picker is already active", null)
            return
        }
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, suggestedName)
            addFlags(
                Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION,
            )
        }
        pendingResult = result
        startActivityForResult(intent, REQUEST_CREATE)
    }

    private fun readDocument(uriString: String, result: MethodChannel.Result) {
        ioExecutor.execute {
            val outcome: IoOutcome = try {
                val uri = Uri.parse(uriString)
                val stream = contentResolver.openInputStream(uri)
                if (stream == null) {
                    IoOutcome.Error("not_found", "Could not open document for reading")
                } else {
                    val content = stream.use { input ->
                        BufferedReader(InputStreamReader(input, Charsets.UTF_8)).use { reader ->
                            reader.readText()
                        }
                    }
                    IoOutcome.Success(content)
                }
            } catch (e: SecurityException) {
                IoOutcome.Error("permission_denied", e.message)
            } catch (e: Exception) {
                IoOutcome.Error("read_failed", e.message)
            }
            post { outcome.deliverTo(result) }
        }
    }

    private fun writeDocument(
        uriString: String,
        content: String,
        result: MethodChannel.Result,
    ) {
        ioExecutor.execute {
            val outcome: IoOutcome = try {
                val uri = Uri.parse(uriString)
                // "wt" truncates the file before writing so shortened content
                // does not leave stale bytes at the tail.
                val stream = contentResolver.openOutputStream(uri, "wt")
                if (stream == null) {
                    IoOutcome.Error("not_found", "Could not open document for writing")
                } else {
                    stream.use { output ->
                        output.write(content.toByteArray(Charsets.UTF_8))
                        output.flush()
                    }
                    IoOutcome.Success(null)
                }
            } catch (e: SecurityException) {
                IoOutcome.Error("permission_denied", e.message)
            } catch (e: Exception) {
                IoOutcome.Error("write_failed", e.message)
            }
            post { outcome.deliverTo(result) }
        }
    }

    private fun post(block: () -> Unit) {
        mainHandler.post { block() }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != REQUEST_OPEN && requestCode != REQUEST_CREATE) return

        val result = pendingResult
        pendingResult = null
        if (result == null) return

        if (resultCode != Activity.RESULT_OK) {
            result.success(null) // user cancelled
            return
        }
        val uri = data?.data
        if (uri == null) {
            result.success(null)
            return
        }

        // Persist permission so subsequent sessions can reopen the document
        // without forcing the user to re-pick it.
        val takeFlags = (data.flags and
            (Intent.FLAG_GRANT_READ_URI_PERMISSION or Intent.FLAG_GRANT_WRITE_URI_PERMISSION))
        try {
            contentResolver.takePersistableUriPermission(uri, takeFlags)
        } catch (_: SecurityException) {
            // Some providers don't support persistable permissions — ignore.
        }

        val displayName = queryDisplayName(uri) ?: "untitled"
        result.success(
            mapOf(
                "uri" to uri.toString(),
                "displayName" to displayName,
            ),
        )
    }

    private fun queryDisplayName(uri: Uri): String? {
        var cursor: Cursor? = null
        return try {
            cursor = contentResolver.query(uri, null, null, null, null)
            if (cursor != null && cursor.moveToFirst()) {
                val index = cursor.getColumnIndex(OpenableColumns.DISPLAY_NAME)
                if (index >= 0) cursor.getString(index) else null
            } else {
                null
            }
        } catch (_: Exception) {
            null
        } finally {
            cursor?.close()
        }
    }

    /** Sum type for the result of a background SAF operation. */
    private sealed class IoOutcome {
        data class Success(val value: Any?) : IoOutcome()
        data class Error(val code: String, val message: String?) : IoOutcome()

        fun deliverTo(result: MethodChannel.Result) {
            when (this) {
                is Success -> result.success(value)
                is Error -> result.error(code, message, null)
            }
        }
    }

    companion object {
        private const val CHANNEL = "com.nolumia.plainpad/saf"
        private const val REQUEST_OPEN = 7001
        private const val REQUEST_CREATE = 7002
    }
}
