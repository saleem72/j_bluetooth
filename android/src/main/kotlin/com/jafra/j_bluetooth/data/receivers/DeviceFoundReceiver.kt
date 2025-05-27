package com.jafra.j_bluetooth.data.receivers


import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import com.jafra.j_bluetooth.data.mappers.toJafraBluetoothDevice
import com.jafra.j_bluetooth.data.mappers.toMap
import io.flutter.plugin.common.EventChannel

import io.flutter.Log
/**
 * It's BroadcastReceiver receive BluetoothDevice.ACTION_FOUND
 * it emits event every time when a new bluetooth device was founded
 */
class DeviceFoundReceiver(
    private val context: Context,
    private val bluetoothAdapter: BluetoothAdapter,
) : EventChannel.StreamHandler {

    companion object {
        const val  TAG = "JBluetoothPlugin"
    }

    private var eventSink: EventChannel.EventSink? = null
    private var isReceiverRegistered = false
    private var bluetoothReceiver: BroadcastReceiver? = null

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        Log.d(TAG, "onListen: BluetoothDiscoveryHelper")
        eventSink = events
//        startDiscovery()
    }

    override fun onCancel(arguments: Any?) {
        stopDiscovery()
    }

    @SuppressLint("MissingPermission")
     fun startDiscovery() {

        Log.d(TAG, "BluetoothDiscoveryHelper: startDiscovery")
        if (bluetoothAdapter.isDiscovering) {
            bluetoothAdapter.cancelDiscovery()
        }

        if (!isReceiverRegistered) {
//            val filter = IntentFilter(BluetoothDevice.ACTION_FOUND)
            val filter = IntentFilter().apply {
                addAction(BluetoothDevice.ACTION_FOUND)
            }
            context.registerReceiver(getReceiver(), filter)
            isReceiverRegistered = true
        }

        val started = bluetoothAdapter.startDiscovery()
        Log.d(TAG, "startDiscovery result: $started")
    }

    @SuppressLint("MissingPermission")
     fun stopDiscovery() {
        bluetoothAdapter.cancelDiscovery()
        if (isReceiverRegistered) {
            context.unregisterReceiver(bluetoothReceiver)
            isReceiverRegistered = false
        }
        eventSink = null
    }

    @Suppress("DEPRECATION")
    private fun getReceiver(): BroadcastReceiver {
        if (bluetoothReceiver == null) {
            bluetoothReceiver = object : BroadcastReceiver() {
                override fun onReceive(ctx: Context?, intent: Intent?) {
                    val action = intent?.action
                    Log.d(TAG, "action: $action")
                    if (intent?.action == BluetoothDevice.ACTION_FOUND) {
                        val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                            intent.getParcelableExtra(
                                BluetoothDevice.EXTRA_DEVICE,
                                BluetoothDevice::class.java
                            )
                        } else {
                            @Suppress("DEPRECATION")
                            intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                        }
                        val rssi: Short = intent.getShortExtra(BluetoothDevice.EXTRA_RSSI, Short.MIN_VALUE)
                        device?.let {
                            Log.d(TAG, "device: $it")
                            eventSink?.success(it.toJafraBluetoothDevice(rssi).toMap())
                        }

                    }
                }
            }
        }
        return bluetoothReceiver!!
    }
}