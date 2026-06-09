package com.hone.mobile

import android.os.Bundle
import com.hone.mobile.vpn.NotImplementedAndroidVpnTunnelService
import com.hone.mobile.vpn.VpnBridge
import com.hone.mobile.vpn.VpnBridgeChannel
import com.hone.mobile.vpn.AndroidVpnTunnelService
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, VpnBridgeChannel.DEFAULT_CHANNEL_NAME)
        val tunnelService: AndroidVpnTunnelService = NotImplementedAndroidVpnTunnelService()
        val bridge = VpnBridge(tunnelService)
        VpnBridgeChannel(this, channel, bridge)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
    }
}

