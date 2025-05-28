package com.jafra.j_bluetooth.data.streams

import android.bluetooth.BluetoothDevice
import io.flutter.plugin.common.EventChannel

class ConnectionStateStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun notifyConnected(remoteDevice: BluetoothDevice) {
        val data = mapOf(
            "address" to remoteDevice.address,
            "name" to remoteDevice.name,
            "isConnected" to true
        )
        eventSink?.success(data)
    }

    fun notifyDisconnected() {
        val data = mapOf(
            "isConnected" to false
        )
        eventSink?.success(data)
    }

    fun notifyError(message: String) {
        val data = mapOf(
            "isConnected" to false,
            "error" to message
        )
        eventSink?.success(data)
    }
}
