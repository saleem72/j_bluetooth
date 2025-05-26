package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.domain.constants.BluetoothConstants
import io.flutter.Log
import java.io.IOException

class BluetoothClient(private val device: BluetoothDevice) {

    fun connect(onConnected: (BluetoothSocket) -> Unit, onError: (Exception) -> Unit) {
        Thread {
            try {
                val socket = device.createRfcommSocketToServiceRecord(BluetoothConstants.uuid)
                socket.connect()
                Log.d("BluetoothClient", "Connected to server")
                onConnected(socket)
            } catch (e: IOException) {
                Log.e("BluetoothClient", "Connection failed: ${e.message}")
                onError(e)
            }
        }.start()
    }
}
