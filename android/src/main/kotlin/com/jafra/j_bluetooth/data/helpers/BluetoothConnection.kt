package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.JBluetoothPlugin
import com.jafra.j_bluetooth.data.streams.ConnectionStateStreamHandler
import com.jafra.j_bluetooth.data.streams.IncomingMessagesStreamHandler
import io.flutter.Log
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream

class BluetoothConnection(
    private val socket: BluetoothSocket,
    private val connectionStateStreamHandler: ConnectionStateStreamHandler?,
    private val incomingMessagesStreamHandler: IncomingMessagesStreamHandler?
) {

    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var isRunning = false

    fun start() {
        inputStream = socket.inputStream
        outputStream = socket.outputStream
        isRunning = true

        Thread {
            val buffer = ByteArray(1024)
            while (isRunning) {
                try {
                    val bytesRead = inputStream?.read(buffer) ?: -1
                    if (bytesRead == -1) {
                        Log.d("BluetoothConnection", "Connection lost (stream closed)")
                        connectionStateStreamHandler?.notifyDisconnected()
                        break
                    }
                    if (bytesRead > 0) {
                        val received = String(buffer, 0, bytesRead)
                        Log.d("BluetoothConnection", "Received: $received")
                        // TODO("Fix this")
                        incomingMessagesStreamHandler?.sendIncomingMessage(received)
                    }
                } catch (e: IOException) {
                    Log.e("BluetoothConnection", "Read failed", e)
                    connectionStateStreamHandler?.notifyDisconnected()
                    break
                }
            }
            isRunning = false
        }.start()
    }

    fun write(data: String) {
        try {
            outputStream?.write(data.toByteArray())
            Log.d("BluetoothConnection", "Sent: $data")
        } catch (e: IOException) {
            Log.e("BluetoothConnection", "Write failed", e)
            connectionStateStreamHandler?.notifyDisconnected()
        }
    }

    fun stop() {
        isRunning = false
        try {
            socket.close()
            Log.d("BluetoothConnection", "Socket closed")
        } catch (e: IOException) {
            Log.e("BluetoothConnection", "Socket close failed", e)
        } finally {
            connectionStateStreamHandler?.notifyDisconnected()
        }
    }
}
