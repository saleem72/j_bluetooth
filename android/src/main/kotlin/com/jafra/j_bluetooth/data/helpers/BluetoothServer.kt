package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.domain.constants.BluetoothConstants
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.util.UUID

class BluetoothServer(private val adapter: BluetoothAdapter) {



    private var serverSocket: BluetoothServerSocket? = null

    fun startServer(
        onConnected: (BluetoothSocket, BluetoothDevice) -> Unit,
        onError: (Exception) -> Unit
    ) {
        var serverSocket: android.bluetooth.BluetoothServerSocket? = null // Declare outside try block
        CoroutineScope(Dispatchers.IO).launch {
            try {
                serverSocket = adapter.listenUsingRfcommWithServiceRecord(
                    BluetoothConstants.appName,
                    BluetoothConstants.uuid
                )
                Log.d("BluetoothServer", "Waiting for client...")
                val socket = serverSocket?.accept() // Blocking call
                Log.d("BluetoothServer", "Client connected")

                socket?.let {
                    val remoteDevice = it.remoteDevice
                    withContext(Dispatchers.Main) {
                        onConnected(it, remoteDevice) // Execute onConnected on UI thread
                    }
                    serverSocket?.close()
                }
            } catch (e: IOException) {
                withContext(Dispatchers.Main) {
                    Log.e("BluetoothServer", "Server error: ${e.message}")
                    onError(e) // Execute onError on UI thread
                }
            } finally {
                serverSocket?.close()
            }
        }
    }

//    fun startServer(onConnected: (BluetoothSocket) -> Unit, onError: (Exception) -> Unit) {
//        Thread {
//            try {
//
//                serverSocket = adapter.listenUsingRfcommWithServiceRecord(
//                    BluetoothConstants.appName,
//                    BluetoothConstants.uuid
//                )
//                Log.d("BluetoothServer", "Waiting for client...")
//                val socket = serverSocket?.accept() // Blocking call
//                Log.d("BluetoothServer", "Client connected")
//                socket?.let {
//                    onConnected(it)
//                    serverSocket?.close()
//                }
//            } catch (e: IOException) {
//                Log.e("BluetoothServer", "Server error: ${e.message}")
//                onError(e)
//            }
//        }.start()
//    }

    fun stopServer() {
        try {
            serverSocket?.close()
        } catch (e: IOException) {
            Log.e("BluetoothServer", "Error closing server: ${e.message}")
        }
    }
}
