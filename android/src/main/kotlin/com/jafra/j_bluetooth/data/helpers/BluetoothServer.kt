package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothServerSocket
import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.data.streams.ServerStatusStreamHandler
import com.jafra.j_bluetooth.domain.constants.BluetoothConstants
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import kotlinx.coroutines.withTimeoutOrNull
import java.io.IOException

class BluetoothServer(
    private val adapter: BluetoothAdapter,
    private val serverStatusStreamHandler: ServerStatusStreamHandler?, ) {



    private var serverSocket: BluetoothServerSocket? = null

    fun startServer(
        timeoutMs: Long = 10000L,
        onConnected: (BluetoothSocket, BluetoothDevice) -> Unit,
        onError: (Exception) -> Unit
    ) {
        var serverSocket: BluetoothServerSocket? = null // Declare outside try block

        serverStatusStreamHandler?.notify(true)
        CoroutineScope(Dispatchers.IO).launch {
            try {
                serverSocket = adapter.listenUsingRfcommWithServiceRecord(
                    BluetoothConstants.appName,
                    BluetoothConstants.uuid
                )

                Log.d("BluetoothServer", "Waiting for client...")

                val socket: BluetoothSocket? = withTimeoutOrNull(timeoutMs) {
                    serverSocket?.accept() // blocking call in IO dispatcher
                }

                if (socket != null) {
                    val remoteDevice = socket.remoteDevice
                    withContext(Dispatchers.Main) {
                        onConnected(socket, remoteDevice)
                        serverStatusStreamHandler?.notify(false)
                    }
                } else {
                    // Timed out waiting for client
                    withContext(Dispatchers.Main) {
                        Log.d("BluetoothServer", "Accept timeout")
                        onError(IOException("Bluetooth accept() timed out"))
                        serverStatusStreamHandler?.notify(false)
                    }
                }

            } catch (e: IOException) {
                withContext(Dispatchers.Main) {
                    Log.e("BluetoothServer", "Server error: ${e.message}")
                    onError(e)
                    serverStatusStreamHandler?.notify(false)
                }
            } finally {
                try {
                    serverSocket?.close()
                } catch (e: IOException) {
                    Log.e("BluetoothServer", "Error closing server socket", e)
                }
                withContext(Dispatchers.Main) {
                    serverStatusStreamHandler?.notify(false)
                }
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
            serverStatusStreamHandler?.notify(false)
        } catch (e: IOException) {
            Log.e("BluetoothServer", "Error closing server: ${e.message}")
            serverStatusStreamHandler?.notify(false)
        }
    }
}
