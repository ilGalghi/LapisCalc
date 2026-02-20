package com.ilgalghi.lapiscalc

import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ilgalghi.lapiscalc/androidversion"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getAndroidVersion") {
                val androidV = getAndroidVersion()
                result.success(androidV)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun getAndroidVersion(): Int {
        return Build.VERSION.SDK_INT
    }
}
