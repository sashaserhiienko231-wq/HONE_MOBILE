package com.hone.mobile.vpn

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result

/**
 * WireGuard/VpnService bridge.
 *
 * NOTE: This is a platform-channel contract layer.
 * The actual VpnService/VpnTunnelManager wiring must be implemented next.
 */
class VpnBridge(
    private val androidVpnTunnelService: AndroidVpnTunnelService,
) {

    object Method {
        const val CONNECT = "connect"
        const val DISCONNECT = "disconnect"
        const val RECONNECT = "reconnect"
        const val GET_STATUS = "getStatus"
        const val GET_TRANSFER_STATS = "getTransferStats"
        const val GET_CURRENT_SERVER = "getCurrentServer"
        const val GET_SESSION_DURATION = "getSessionDuration"
        const val IMPORT_WG_CONF = "importWireGuardConfig"
    }

    fun connect(call: MethodCall, result: Result) {
        val serverId = call.argument<String>("serverId")
        val rawConfig = call.argument<String>("wireGuardConfig")

        androidVpnTunnelService.connect(serverId, rawConfig, result)
    }

    fun disconnect(result: Result) {
        androidVpnTunnelService.disconnect(result)
    }

    fun reconnect(result: Result) {
        androidVpnTunnelService.reconnect(result)
    }

    fun getStatus(result: Result) {
        androidVpnTunnelService.getStatus(result)
    }

    fun getTransferStats(result: Result) {
        androidVpnTunnelService.getTransferStats(result)
    }

    fun getCurrentServer(result: Result) {
        androidVpnTunnelService.getCurrentServer(result)
    }

    fun getSessionDuration(result: Result) {
        androidVpnTunnelService.getSessionDuration(result)
    }

    fun importWireGuardConfig(call: MethodCall, result: Result) {
        val rawConfig = call.argument<String>("wireGuardConfig")
        val serverId = call.argument<String>("serverId")
        androidVpnTunnelService.importWireGuardConfig(serverId, rawConfig, result)
    }
}

/**
 * Abstraction so we can implement real tunneling in Android without breaking the channel contract.
 */
interface AndroidVpnTunnelService {
    fun connect(serverId: String?, rawConfig: String?, result: Result)
    fun disconnect(result: Result)
    fun reconnect(result: Result)
    fun getStatus(result: Result)
    fun getTransferStats(result: Result)
    fun getCurrentServer(result: Result)
    fun getSessionDuration(result: Result)
    fun importWireGuardConfig(serverId: String?, rawConfig: String?, result: Result)
}

