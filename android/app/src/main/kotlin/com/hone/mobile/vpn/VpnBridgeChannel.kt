package com.hone.mobile.vpn

import android.content.Context
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class VpnBridgeChannel(
    private val context: Context,
    private val channel: MethodChannel,
    private val bridge: VpnBridge,
) : MethodCallHandler {

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            VpnBridge.Method.CONNECT -> {
                bridge.connect(call, result)
            }
            VpnBridge.Method.DISCONNECT -> {
                bridge.disconnect(result)
            }
            VpnBridge.Method.RECONNECT -> {
                bridge.reconnect(result)
            }
            VpnBridge.Method.GET_STATUS -> {
                bridge.getStatus(result)
            }
            VpnBridge.Method.GET_TRANSFER_STATS -> {
                bridge.getTransferStats(result)
            }
            VpnBridge.Method.GET_CURRENT_SERVER -> {
                bridge.getCurrentServer(result)
            }
            VpnBridge.Method.GET_SESSION_DURATION -> {
                bridge.getSessionDuration(result)
            }
            VpnBridge.Method.IMPORT_WG_CONF -> {
                bridge.importWireGuardConfig(call, result)
            }
            else -> result.notImplemented()
        }
    }

    companion object {
        const val DEFAULT_CHANNEL_NAME = "hone_mobile_vpn"
    }
}

