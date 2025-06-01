package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.data.streams.ServerStatusStreamHandler
import com.jafra.j_bluetooth.domain.constants.BluetoothConstants
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.TimeoutCancellationException
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeout
import java.io.IOException

class BluetoothClient(
    private val device: BluetoothDevice,
    private val serverStatusStreamHandler: ServerStatusStreamHandler?
) {

    fun connect(
        timeoutMs: Int = 15000,
        onConnected: (BluetoothSocket, BluetoothDevice) -> Unit,
        onError: (Exception) -> Unit
    ) {
        serverStatusStreamHandler?.notify(connectionStatus = true)
        CoroutineScope(Dispatchers.IO).launch {
            try {
                val socket = device.createRfcommSocketToServiceRecord(BluetoothConstants.uuid)
                withTimeout(timeoutMs.toLong()) {
                    socket.connect()
                }
                Log.d("BluetoothClient", "Connected to server")
                val remoteDevice = socket.remoteDevice
                withContext(Dispatchers.Main) {
                    onConnected(socket, remoteDevice)
                    serverStatusStreamHandler?.notify(connectionStatus = false)
                }

            } catch (e: TimeoutCancellationException) {
                Log.d("BluetoothClient", "BluetoothClient error: socket connect() timed out")
                withContext(Dispatchers.Main) {
                    onError(e)
                    serverStatusStreamHandler?.notify(connectionStatus = false)
                }
            }

            catch (e: IOException) {
                Log.e("BluetoothClient", "Connection failed: ${e.message}")
                withContext(Dispatchers.Main) {
                    onError(e)
                    serverStatusStreamHandler?.notify(connectionStatus = false)
                }

            }
        }
    }
}
