package com.jafra.j_bluetooth.data.receivers

import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log
import io.flutter.plugin.common.EventChannel

/**
 * ACL (Asynchronous Connection-Less)
 * You can receive these broadcasts even without bonding, e.g., when using insecure connections.
 */
class AclConnectionReceiver(private val context: Context) : EventChannel.StreamHandler {

    private var eventSink: EventChannel.EventSink? = null
    private var receiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
        registerReceiver()
    }

    override fun onCancel(arguments: Any?) {
        unregisterReceiver()
        eventSink = null
    }

    private fun registerReceiver() {
        Log.d("JBluetoothPlugin", "register AclConnectionReceiver")
        val filter = IntentFilter().apply {
            addAction(BluetoothDevice.ACTION_ACL_CONNECTED)
            addAction(BluetoothDevice.ACTION_ACL_DISCONNECTED)
        }

        receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent == null) return

                val action = intent.action
                Log.d("JBluetoothPlugin", "onReceive: $action")
                val device: BluetoothDevice? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }

                if (device != null && eventSink != null) {
                    val isConnected = when (action) {
                        BluetoothDevice.ACTION_ACL_CONNECTED -> true
                        BluetoothDevice.ACTION_ACL_DISCONNECTED -> false
                        else -> return
                    }

                    val data = mapOf(
                        "address" to device.address,
                        "name" to device.name,
                        "isConnected" to isConnected
                    )

                    eventSink?.success(data)
                }
            }
        }

        context.registerReceiver(receiver, filter)
    }

    private fun unregisterReceiver() {
        if (receiver != null) {
            context.unregisterReceiver(receiver)
            receiver = null
        }
    }
}
