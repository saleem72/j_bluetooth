package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.data.streams.ConnectionStateStreamHandler
import com.jafra.j_bluetooth.data.streams.IncomingMessagesStreamHandler
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.nio.ByteBuffer
import java.nio.ByteOrder

class BluetoothConnection(
    private val socket: BluetoothSocket,
    private val connectionStateStreamHandler: ConnectionStateStreamHandler?,
    private val incomingMessagesStreamHandler: IncomingMessagesStreamHandler?,
    private val onLostConnection: () -> Unit
) {

    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var isRunning = false

    fun temp1() {
        inputStream = socket.inputStream
        outputStream = socket.outputStream
        isRunning = true

        CoroutineScope(Dispatchers.IO).launch {
            val buffer = ByteArray(1024)
            while (isRunning) {
                try {
                    val bytesRead = inputStream?.read(buffer) ?: -1
                    if (bytesRead == -1) {
                        Log.d("BluetoothConnection", "Connection lost (stream closed)")
                        withContext(Dispatchers.Main) {
                            connectionStateStreamHandler?.notifyDisconnected()
                        }

                        break
                    }
                    if (bytesRead > 0) {
                        val received = String(buffer, 0, bytesRead)
                        Log.d("BluetoothConnection", "Received: $received")
                        withContext(Dispatchers.Main) {
                            incomingMessagesStreamHandler?.sendIncomingMessage(received)
                        }

                    }
                } catch (e: IOException) {
                    withContext(Dispatchers.Main) {
                        connectionStateStreamHandler?.notifyDisconnected()
                        onLostConnection()
                    }

                    break
                }
            }
            isRunning = false
        }
    }

    fun start() {
        inputStream = socket.inputStream
        outputStream = socket.outputStream
        isRunning = true

        CoroutineScope(Dispatchers.IO).launch {
            try {
                val typeBuffer = ByteArray(1)
                val sizeBuffer = ByteArray(4)

                while (isRunning) {
                    // Read message type
                    val typeRead = inputStream?.read(typeBuffer) ?: -1
                    if (typeRead == -1) break

                    when (typeBuffer[0]) {
                        0x01.toByte() -> { // Text message
                            Log.d("BluetoothConnection", "received type: Text Message" )
                            val textBuffer = ByteArray(1024)
                            val len = inputStream?.read(textBuffer) ?: -1
                            if (len > 0) {
                                val message = String(textBuffer, 0, len)

                                Log.d("received data", message )
                                withContext(Dispatchers.Main) {
                                    incomingMessagesStreamHandler?.sendIncomingMessage(message)
                                }
                            }
                        }

                        0x02.toByte() -> { // File transfer
                            // Read 4-byte file size
                            Log.d("BluetoothConnection", "received type: File transfer" )
                            var totalSizeRead = 0
                            while (totalSizeRead < 4) {
                                val read = inputStream?.read(sizeBuffer, totalSizeRead, 4 - totalSizeRead) ?: -1
                                if (read == -1) throw IOException("Stream closed while reading file size")
                                totalSizeRead += read
                            }
                            val fileSize = ByteBuffer.wrap(sizeBuffer).order(ByteOrder.BIG_ENDIAN).int

                            if (fileSize > 2 * 1024 * 1024) {
                                throw IOException("File too large: $fileSize")
                            }

                            val fileBuffer = ByteArray(fileSize)
                            var readTotal = 0
                            while (readTotal < fileSize) {
                                val read = inputStream?.read(fileBuffer, readTotal, fileSize - readTotal) ?: -1
                                if (read == -1) throw IOException("Connection lost during file read")
                                readTotal += read
                            }

                            val actualPayload = fileBuffer.copyOfRange(1, fileBuffer.size) // remove 0x02 prefix
                            val base64 = String(actualPayload, Charsets.UTF_8) // now it's exactly what Flutter sent
                            Log.d("received data", base64 )
                            withContext(Dispatchers.Main) {
                                incomingMessagesStreamHandler?.sendIncomingMessage(base64)

                            }
                        }

                        else -> {
                            Log.w("BluetoothConnection", "Unknown message type: ${typeBuffer[0]}")
                        }
                    }
                }

            } catch (e: IOException) {
                Log.e("BluetoothConnection", "Error receiving file", e)
                withContext(Dispatchers.Main) {
                    connectionStateStreamHandler?.notifyDisconnected()
                    onLostConnection()
                }
            } finally {
                isRunning = false
            }
        }
    }

    fun writeTemp(data: String) {
        try {
            outputStream?.write(data.toByteArray())
            Log.d("BluetoothConnection", "Sent: $data")
        } catch (e: IOException) {
            Log.e("BluetoothConnection", "Write failed", e)
            connectionStateStreamHandler?.notifyDisconnected()
        }
    }

    fun write(data: String, isFile: Boolean ) {
        Log.d("BluetoothConnection", "isFile: $isFile" )
        try {
            val dataBytes = data.toByteArray()
            val message: ByteArray = if (isFile) {
                // Prefix with 0x02 (file), then 4-byte length, then file data
                val lengthPrefix = ByteBuffer.allocate(4).order(ByteOrder.BIG_ENDIAN).putInt(dataBytes.size).array()
                val finalMessage = ByteArray(1 + 4 + dataBytes.size)
                finalMessage[0] = 0x02 // file type
                System.arraycopy(lengthPrefix, 0, finalMessage, 1, 4)
                System.arraycopy(dataBytes, 0, finalMessage, 5, dataBytes.size)
                finalMessage
            } else {
                // Prefix with 0x01 (text), then text data
                val finalMessage = ByteArray(1 + dataBytes.size)
                finalMessage[0] = 0x01 // text type
                System.arraycopy(dataBytes, 0, finalMessage, 1, dataBytes.size)
                finalMessage
            }

            outputStream?.write(message)
            Log.d("BluetoothConnection", "Sent (${if (isFile) "file" else "text"}): ${data.take(100)}")
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
