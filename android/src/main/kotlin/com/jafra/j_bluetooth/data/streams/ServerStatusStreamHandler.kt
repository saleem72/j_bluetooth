package com.jafra.j_bluetooth.data.streams

import io.flutter.plugin.common.EventChannel

class ServerStatusStreamHandler : EventChannel.StreamHandler {
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    fun notify(serverStatus: Boolean? = null, connectionStatus: Boolean? = null) {
        val data:  HashMap<String, Any?> = HashMap()
        serverStatus?.let { data["serverStatus"] = it }
        connectionStatus?.let { data["connectionStatus"] = it }
        eventSink?.success(data)
    }

}
