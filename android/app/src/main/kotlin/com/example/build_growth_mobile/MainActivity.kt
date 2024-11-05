package com.bug.build_growth_mobile

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant

import android.content.Intent
import android.provider.Settings
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity(){
     private val CHANNEL = "com.bug.build_growth_mobile/nfc"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngine.plugins.add(EmvCardReaderPlugin()) // Register the plugin here

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "openNFCSettings") {
                val intent = Intent(Settings.ACTION_NFC_SETTINGS)
                startActivity(intent)
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
