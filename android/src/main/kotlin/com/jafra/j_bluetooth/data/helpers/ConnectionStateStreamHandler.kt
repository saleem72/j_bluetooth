package com.jafra.j_bluetooth.data.helpers

import io.flutter.plugin.common.EventChannel

class ConnectionStateStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun notifyConnected() {
        eventSink?.success("connected")
    }

    fun notifyDisconnected() {
        eventSink?.success("disconnected")
    }

    fun notifyError(message: String) {
        eventSink?.error("CONNECTION_ERROR", message, null)
    }
}
