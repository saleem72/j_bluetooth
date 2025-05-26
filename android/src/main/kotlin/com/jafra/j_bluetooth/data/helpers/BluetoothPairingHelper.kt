package com.jafra.j_bluetooth.data.helpers


import android.annotation.SuppressLint
import android.bluetooth.BluetoothDevice
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.util.Log

class BluetoothPairingHelper(private val context: Context) {

    interface PairingCallback {
        fun onBonding(device: BluetoothDevice)
        fun onBonded(device: BluetoothDevice)
        fun onBondingFailed(device: BluetoothDevice)
    }

    private var callback: PairingCallback? = null

    @Suppress("DEPRECATION")
    private val pairingReceiver = object : BroadcastReceiver() {
        @SuppressLint("MissingPermission")
        override fun onReceive(context: Context, intent: Intent) {
            val action = intent.action
            if (action == BluetoothDevice.ACTION_BOND_STATE_CHANGED) {
                val device = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                    intent.getParcelableExtra(
                        BluetoothDevice.EXTRA_DEVICE,
                        BluetoothDevice::class.java
                    )
                } else {
                    @Suppress("DEPRECATION")
                    intent.getParcelableExtra(BluetoothDevice.EXTRA_DEVICE)
                }
                val bondState = intent.getIntExtra(BluetoothDevice.EXTRA_BOND_STATE, BluetoothDevice.BOND_NONE)

                when (bondState) {
                    BluetoothDevice.BOND_BONDED -> {
                        Log.d("PairingHelper", "Bonded with ${device?.name}")
                        device?.let { callback?.onBonded(it) }
                    }
                    BluetoothDevice.BOND_BONDING -> {
                        Log.d("PairingHelper", "Bonding with ${device?.name}")
                        device?.let { callback?.onBonding(it) }
                    }
                    BluetoothDevice.BOND_NONE -> {
                        Log.d("PairingHelper", "Bonding failed with ${device?.name}")
                        device?.let { callback?.onBondingFailed(it) }
                    }
                }
            }
        }
    }

    @SuppressLint("MissingPermission")
    fun pairDevice(device: BluetoothDevice, callback: PairingCallback) {
        this.callback = callback

        // Register receiver
        val filter = IntentFilter(BluetoothDevice.ACTION_BOND_STATE_CHANGED)
        context.registerReceiver(pairingReceiver, filter)

        if (device.bondState != BluetoothDevice.BOND_BONDED) {
            device.createBond()
        } else {
            callback.onBonded(device) // Already paired
        }
    }

    fun cleanup() {
        try {
            context.unregisterReceiver(pairingReceiver)
        } catch (e: IllegalArgumentException) {
            // Already unregistered or not registered
        }
    }
}