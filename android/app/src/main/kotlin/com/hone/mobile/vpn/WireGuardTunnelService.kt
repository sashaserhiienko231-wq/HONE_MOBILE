package com.hone.mobile.vpn

import android.content.Context

/**
 * TODO: Replace this placeholder with a production implementation based on
 * com.wireguard.android:wireguard-android.
 */
class WireGuardTunnelService(
    private val context: Context,
) : AndroidVpnTunnelService {

    private val delegate = NotImplementedAndroidVpnTunnelService()

    override fun connect(serverId: String?, rawConfig: String?, result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.connect(serverId, rawConfig, result)
    }

    override fun disconnect(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.disconnect(result)
    }

    override fun reconnect(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.reconnect(result)
    }

    override fun getStatus(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.getStatus(result)
    }

    override fun getTransferStats(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.getTransferStats(result)
    }

    override fun getCurrentServer(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.getCurrentServer(result)
    }

    override fun getSessionDuration(result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.getSessionDuration(result)
    }

    override fun importWireGuardConfig(serverId: String?, rawConfig: String?, result: io.flutter.plugin.common.MethodChannel.Result) {
        delegate.importWireGuardConfig(serverId, rawConfig, result)
    }
}

