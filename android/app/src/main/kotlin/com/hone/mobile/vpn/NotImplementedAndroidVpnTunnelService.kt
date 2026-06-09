package com.hone.mobile.vpn

import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.atomic.AtomicReference

/**
 * Temporary service implementation.
 *
 * It provides explicit "Not Configured" style outputs instead of fake metrics.
 * Next step is to replace this with a real VpnService + WireGuard runtime integration.
 */
class NotImplementedAndroidVpnTunnelService : AndroidVpnTunnelService {

    private val statusRef = AtomicReference<Map<String, Any?>>(
        mapOf(
            "state" to "disconnected",
            "tunnelStatus" to "Not Configured",
            "serverEndpoint" to "Not Configured",
            "handshakeTimeMs" to null,
        )
    )

    override fun connect(serverId: String?, rawConfig: String?, result: io.flutter.plugin.common.MethodChannel.Result) {
        statusRef.set(
            mapOf(
                "state" to "error",
                "tunnelStatus" to "Not Configured",
                "serverEndpoint" to "Not Configured",
                "handshakeTimeMs" to null,
                "error" to "WireGuard runtime not wired yet"
            )
        )
        result.error("NOT_CONFIGURED", "WireGuard runtime not wired yet", null)
    }

    override fun disconnect(result: io.flutter.plugin.common.MethodChannel.Result) {
        statusRef.set(
            mapOf(
                "state" to "disconnected",
                "tunnelStatus" to "Not Configured",
                "serverEndpoint" to "Not Configured",
                "handshakeTimeMs" to null,
            )
        )
        result.success(null)
    }

    override fun reconnect(result: io.flutter.plugin.common.MethodChannel.Result) {
        result.error("NOT_CONFIGURED", "WireGuard runtime not wired yet", null)
    }

    override fun getStatus(result: io.flutter.plugin.common.MethodChannel.Result) {
        result.success(statusRef.get())
    }

    override fun getTransferStats(result: io.flutter.plugin.common.MethodChannel.Result) {
        result.success(
            mapOf(
                "bytesSent" to null,
                "bytesReceived" to null,
                "downloadMbps" to null,
                "uploadMbps" to null,
            )
        )
    }

    override fun getCurrentServer(result: io.flutter.plugin.common.MethodChannel.Result) {
        result.success(
            mapOf(
                "serverId" to null,
                "region" to "Not Configured",
                "endpoint" to "Not Configured",
            )
        )
    }

    override fun getSessionDuration(result: io.flutter.plugin.common.MethodChannel.Result) {
        result.success(
            mapOf(
                "durationMs" to null,
            )
        )
    }

    override fun importWireGuardConfig(
        serverId: String?,
        rawConfig: String?,
        result: io.flutter.plugin.common.MethodChannel.Result
    ) {
        result.error("NOT_CONFIGURED", "WireGuard runtime not wired yet", null)
    }
}

