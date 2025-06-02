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
import java.io.IOException

class BluetoothServer(
    private val adapter: BluetoothAdapter,
    private val serverStatusStreamHandler: ServerStatusStreamHandler?
) {
    private var serverSocket: BluetoothServerSocket? = null

    fun startServer(
        timeoutMs: Int = 15000,
        onConnected: (BluetoothSocket, BluetoothDevice) -> Unit,
        onError: (Exception) -> Unit
    ) {

        Log.d("BluetoothServer", "timeoutMs: $timeoutMs")
        var serverSocket: BluetoothServerSocket? = null // Declare outside try block

        serverStatusStreamHandler?.notify(serverStatus = true)
        CoroutineScope(Dispatchers.IO).launch {
            try {
                serverSocket = adapter.listenUsingRfcommWithServiceRecord(
                    BluetoothConstants.appName,
                    BluetoothConstants.uuid
                )
                Log.d("BluetoothServer", "Some thing has changed...")
                Log.d("BluetoothServer", "Waiting for client...")
                val socket = serverSocket?.accept() // Blocking call
                Log.d("BluetoothServer", "Client connected")

                socket?.let {
                    val remoteDevice = it.remoteDevice
                    withContext(Dispatchers.Main) {
                        onConnected(it, remoteDevice) // Execute onConnected on UI thread
                        serverStatusStreamHandler?.notify(false)
                    }
                    serverSocket?.close()
                }
            } catch (e: IOException) {
                withContext(Dispatchers.Main) {
                    Log.e("BluetoothServer", "Server error: ${e.message}")
                    onError(e) // Execute onError on UI thread
                    serverStatusStreamHandler?.notify(false)
                }
            } finally {
                serverSocket?.close()
                withContext(Dispatchers.Main) {
                    serverStatusStreamHandler?.notify(false)
                }
            }
//            try {
//                serverSocket = adapter.listenUsingRfcommWithServiceRecord(
//                    BluetoothConstants.appName,
//                    BluetoothConstants.uuid
//                )
//
//                Log.d("BluetoothServer", "Waiting for client...")
//                val socket: BluetoothSocket? = serverSocket?.accept(timeoutMs)
//                Log.d("BluetoothServer", "Waiting has ended")
//
//                if (socket != null) {
//                    val remoteDevice = socket.remoteDevice
//                    withContext(Dispatchers.Main) {
//                        onConnected(socket, remoteDevice)
//                        serverStatusStreamHandler?.notify(serverStatus = false)
//                    }
//                } else {
//                    // Timed out waiting for client
//                    withContext(Dispatchers.Main) {
//                        Log.d("BluetoothServer", "Accept timeout")
//                        onError(IOException("Bluetooth accept() timed out"))
//                        serverStatusStreamHandler?.notify(serverStatus = false)
//                    }
//                }
//
//            } catch (e: IOException) {
//                Log.d("Server error", "startServer: Bluetooth accept() timed out")
//                withContext(Dispatchers.Main) {
//                    onError(e)
//                    serverStatusStreamHandler?.notify(serverStatus = false)
//                }
//            } finally {
//                try {
//                    serverSocket?.close()
//                } catch (e: IOException) {
//                    Log.e("BluetoothServer", "Error closing server socket", e)
//                }
//                withContext(Dispatchers.Main) {
//                    serverStatusStreamHandler?.notify(serverStatus = false)
//                }
//            }
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
