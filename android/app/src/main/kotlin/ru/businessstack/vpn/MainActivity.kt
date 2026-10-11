package ru.businessstack.vpn

import android.content.Intent
import android.net.VpnService
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "ru.businessstack.vpn/vpn"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "startVpn" -> {
                        val intent = VpnService.prepare(this)
                        if (intent != null) {
                            startActivityForResult(intent, 1)
                            result.success(false) // нужно разрешение
                        } else {
                            startVpnService()
                            result.success(true)
                        }
                    }
                    "stopVpn" -> {
                        stopVpnService()
                        result.success(true)
                    }
                    "isVpnRunning" -> {
                        result.success(false) // упрощённо
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun startVpnService() {
        val intent = Intent(this, MyVpnService::class.java).apply {
            action = MyVpnService.ACTION_CONNECT
        }
        startService(intent)
    }

    private fun stopVpnService() {
        val intent = Intent(this, MyVpnService::class.java).apply {
            action = MyVpnService.ACTION_DISCONNECT
        }
        startService(intent)
    }
}