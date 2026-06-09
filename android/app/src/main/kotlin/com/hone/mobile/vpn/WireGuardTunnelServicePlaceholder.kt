package com.hone.mobile.vpn

import android.content.Intent

/**
 * Placeholder class.
 *
 * Replace with actual WireGuard TunnelManager + VpnService implementation.
 */
class WireGuardTunnelServicePlaceholder {
    companion object {
        const val ACTION_CONNECT = "hone.vpn.CONNECT"
        const val ACTION_DISCONNECT = "hone.vpn.DISCONNECT"

        fun connectIntent(): Intent = Intent(ACTION_CONNECT)
        fun disconnectIntent(): Intent = Intent(ACTION_DISCONNECT)
    }
}

