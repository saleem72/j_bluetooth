package com.jafra.j_bluetooth.data.streams

import io.flutter.plugin.common.EventChannel

class IncomingMessagesStreamHandler : EventChannel.StreamHandler  {
    private var eventSink: EventChannel.EventSink? = null
    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun sendIncomingMessage(message: String) {
        eventSink?.success(message)
    }
}