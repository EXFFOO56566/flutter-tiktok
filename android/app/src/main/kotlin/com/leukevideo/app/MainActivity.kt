package com.leukevideo.app

import android.app.Activity
import androidx.annotation.NonNull
//import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.os.Bundle
import android.util.Base64
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import java.security.MessageDigest
import java.security.NoSuchAlgorithmException
import android.content.Context

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.flutter.epic/epic"

  override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)
    MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
      call, result ->
      if (call.method == "printHashKeyOnConsoleLog") {
        val info: PackageInfo = this@MainActivity.getPackageManager().getPackageInfo(this@MainActivity.getPackageName(), PackageManager.GET_SIGNATURES)
        for (signature in info.signatures) {
                val md = MessageDigest.getInstance("SHA")
                md.update(signature.toByteArray())
                val hashKey = String(Base64.encode(md.digest(), 0))
                Log.i("MainActivity", "printHashKey() Hash Key: $hashKey")
            }
      }
    }
  }
}
