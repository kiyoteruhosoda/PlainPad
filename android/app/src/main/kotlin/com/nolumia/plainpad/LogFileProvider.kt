package com.nolumia.plainpad

import android.content.Context
import android.net.Uri
import androidx.core.content.FileProvider
import java.io.File

/**
 * Hands the copy of the logs being shared to the app the person picks
 * (task #913, template flutterbase ADR-0018).
 *
 * Its own subclass so it never collides with another FileProvider an app
 * built from this template declares (two <provider> entries naming
 * androidx.core.content.FileProvider are one component to Android).
 * Only cache/shared_logs/ is reachable (res/xml/log_file_paths.xml, named
 * by the <provider>'s meta-data in AndroidManifest.xml).
 */
class LogFileProvider : FileProvider() {
    companion object {
        fun uriFor(context: Context, file: File): Uri =
            getUriForFile(context, "${context.packageName}.logs", file)
    }
}
