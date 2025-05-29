package com.jafra.j_bluetooth.data.streams

import io.flutter.plugin.common.EventChannel

class ErrorStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendError(message: String, code: String = "PLUGIN_ERROR") {
        eventSink?.success(mapOf("code" to code, "message" to message))
    }
}