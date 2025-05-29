package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.domain.constants.BluetoothConstants
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.io.IOException

class BluetoothClient(private val device: BluetoothDevice) {

    fun connect(
        timeoutMs: Long = 10000L,
        onConnected: (BluetoothSocket, BluetoothDevice) -> Unit,
        onError: (Exception) -> Unit
    ) {
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val socket = device.createRfcommSocketToServiceRecord(BluetoothConstants.uuid)
                withTimeout(timeoutMs) {
                    socket.connect()
                }
                Log.d("BluetoothClient", "Connected to server")
                val remoteDevice = socket.remoteDevice
                withContext(Dispatchers.Main) {
                    onConnected(socket, remoteDevice)
                }

            } catch (e: IOException) {
                Log.e("BluetoothClient", "Connection failed: ${e.message}")
                withContext(Dispatchers.Main) {
                    onError(e)
                }

            }
        }
    }
}
