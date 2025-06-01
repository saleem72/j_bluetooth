package com.jafra.j_bluetooth.data.streams

import android.bluetooth.BluetoothDevice
import io.flutter.plugin.common.EventChannel

class ServerStatusStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun notify(status: Boolean) {
        val data = mapOf(
            "status" to status
        )
        eventSink?.success(data)
    }

}
