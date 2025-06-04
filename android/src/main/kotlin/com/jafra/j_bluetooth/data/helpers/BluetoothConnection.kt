package com.jafra.j_bluetooth.data.helpers

import android.bluetooth.BluetoothSocket
import com.jafra.j_bluetooth.data.streams.ConnectionStateStreamHandler
import com.jafra.j_bluetooth.data.streams.IncomingMessagesStreamHandler
import io.flutter.Log
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import java.io.ByteArrayOutputStream
import java.io.IOException
import java.io.InputStream
import java.io.OutputStream
import java.nio.ByteBuffer

class BluetoothConnection(
    private val socket: BluetoothSocket,
    private val connectionStateStreamHandler: ConnectionStateStreamHandler?,
    private val incomingMessagesStreamHandler: IncomingMessagesStreamHandler?,
    private val onLostConnection: () -> Unit
) {

    private var inputStream: InputStream? = null
    private var outputStream: OutputStream? = null
    private var isRunning = false

    fun start() {
        inputStream = socket.inputStream
        outputStream = socket.outputStream
        isRunning = true

        CoroutineScope(Dispatchers.IO).launch {
            val sizeBuffer = ByteArray(4) // Buffer to read the string size
            var receivedSize: Int? = null
            val receivedData = ByteArrayOutputStream() // Buffer for accumulating received data

            while (isRunning) {
                try {
                    Log.d("BluetoothConnection", "Get in process")

                    if (receivedSize == null) {
                        // Read the 4 bytes representing the string size
                        val bytesReadSize = inputStream?.read(sizeBuffer) ?: -1
                        if (bytesReadSize > 0) {
                            receivedSize = ByteBuffer.wrap(sizeBuffer).getInt()
                            Log.d("BluetoothConnection", "Received expected size: $receivedSize")
                        } else if (bytesReadSize == -1) {
                            // End of stream
                            withContext(Dispatchers.Main) {
                                connectionStateStreamHandler?.notifyDisconnected()
                                onLostConnection()
                            }
                            break
                        }
                    }

                    if (receivedSize != null) {
                        // Read the string data in chunks until the full size is received
                        val buffer = ByteArray(1024) // Adjust buffer size
                        val bytesToRead = minOf(buffer.size, receivedSize - receivedData.size())

                        if (bytesToRead > 0) {
                            val bytesReadData = inputStream?.read(buffer, 0, bytesToRead) ?: -1
                            if (bytesReadData > 0) {
                                receivedData.write(buffer, 0, bytesReadData)
                                Log.d("BluetoothConnection", "Received data chunk: $bytesReadData bytes, total received: ${receivedData.size()}")

                                if (receivedData.size() == receivedSize) {
                                    // Full string received
                                    val receivedString = receivedData.toString()
                                    Log.d("BluetoothConnection", "Received complete string: $receivedString")
                                    withContext(Dispatchers.Main) {
                                        incomingMessagesStreamHandler?.sendIncomingMessage(receivedString)
                                    }

                                    // Reset for the next message
                                    receivedSize = null
                                    receivedData.reset()
                                }
                            } else if (bytesReadData == -1) {
                                // End of stream
                                withContext(Dispatchers.Main) {
                                    connectionStateStreamHandler?.notifyDisconnected()
                                    onLostConnection()
                                }
                                break
                            }
                        }
                    }
                } catch (e: IOException) {
                    withContext(Dispatchers.Main) {
                        connectionStateStreamHandler?.notifyDisconnected()
                        onLostConnection()
                    }
                    break
                } catch (e: Exception) {
                    Log.e("BluetoothConnection", "An unexpected error occurred", e)
                    withContext(Dispatchers.Main) {
                        // Optionally, handle the unexpected exception differently
                    }
                }
            }
            isRunning = false
        }
    }

    fun startTemp() {
        inputStream = socket.inputStream
        outputStream = socket.outputStream
        isRunning = true

        CoroutineScope(Dispatchers.IO).launch {
            val buffer = ByteArray(1024) // Adjust buffer size
            val receivedData = ByteArrayOutputStream() // Buffer for accumulating received data

            while (isRunning) {
                try {
                    Log.d("BluetoothConnection", "Something happened")
                    val bytesRead = inputStream?.read(buffer) ?: -1 // Read into buffer
                    if (bytesRead > 0) {
                        receivedData.write(buffer, 0, bytesRead) // Append to receivedData

                        // Check for header or delimiter to process received data
                        if (receivedData.size() >= 5) { // Check for header size
                            val receivedBytes = receivedData.toByteArray()
                            val dataType = receivedBytes[0].toInt()

                            if (dataType == 0) { // Short message
                                val delimiterIndex = receivedBytes.indexOf("\n".toByte()) // Find delimiter
                                if (delimiterIndex != -1) {
                                    val message = String(receivedBytes, 1, delimiterIndex - 1)
                                    Log.d("BluetoothConnection", "Received short message: $message")
                                    withContext(Dispatchers.Main) {
                                        incomingMessagesStreamHandler?.sendIncomingMessage(message)
                                    }
                                    receivedData.reset() // Clear buffer for next message
                                }
                            } else if (dataType == 1 && receivedData.size() >= 5) { // File
                                val fileSize = ByteBuffer.wrap(receivedBytes, 1, 4).getInt() // Extract file size
                                if (receivedData.size() >= fileSize + 5) { // Check if full file received
                                    val fileContent = receivedBytes.copyOfRange(5, fileSize + 5)
                                    val base64 = String(fileContent, Charsets.UTF_8)
                                    Log.d("BluetoothConnection", "Received file of size: $fileSize")
                                    // Process the received file content (e.g., save to storage)
                                    withContext(Dispatchers.Main) {
                                        // Handle the received file content
                                        incomingMessagesStreamHandler?.sendIncomingMessage(base64)
                                    }
                                    receivedData.reset() // Clear buffer for next file
                                }
                            }
                        }
                    } else if (bytesRead == -1) { // End of stream
                        withContext(Dispatchers.Main) {
                            connectionStateStreamHandler?.notifyDisconnected()
                            onLostConnection()
                        }
                        break
                    }
                } catch (e: IOException) {
                    withContext(Dispatchers.Main) {
                        connectionStateStreamHandler?.notifyDisconnected()
                        onLostConnection()
                    }
                    break
                } catch (e: Exception) {
                    // Catch any other exception
                    Log.e("BluetoothConnection", "An unexpected error occurred", e)
                    withContext(Dispatchers.Main) {
                        // Optionally, handle the unexpected exception differently
                    }
                    // Decide whether to break or continue based on the nature of the exception
                    // break // Uncomment if you want to exit the loop on any other exception
                }
            }
            isRunning = false
        }
    }

//    fun start() {
//        inputStream = socket.inputStream
//        outputStream = socket.outputStream
//        isRunning = true
//
//        CoroutineScope(Dispatchers.IO).launch {
//            val buffer = ByteArray(1024)
//            while (isRunning) {
//                try {
//                    val bytesRead = inputStream?.read(buffer) ?: -1
//                    if (bytesRead == -1) {
//                        Log.d("BluetoothConnection", "Connection lost (stream closed)")
//                        withContext(Dispatchers.Main) {
//                            connectionStateStreamHandler?.notifyDisconnected()
//                        }
//
//                        break
//                    }
//                    if (bytesRead > 0) {
//                        val received = String(buffer, 0, bytesRead)
//                        Log.d("BluetoothConnection", "Received: $received")
//                        withContext(Dispatchers.Main) {
//                            incomingMessagesStreamHandler?.sendIncomingMessage(received)
//                        }
//
//                    }
//                } catch (e: IOException) {
//                    withContext(Dispatchers.Main) {
//                        connectionStateStreamHandler?.notifyDisconnected()
//                        onLostConnection()
//                    }
//
//                    break
//                }
//            }
//            isRunning = false
//        }
//    }

//    fun start() {
//        inputStream = socket.inputStream
//        outputStream = socket.outputStream
//        isRunning = true
//
//        CoroutineScope(Dispatchers.IO).launch {
//            try {
//                val typeBuffer = ByteArray(1)
//                val sizeBuffer = ByteArray(4)
//
//                while (isRunning) {
//                    // Read message type
//                    val typeRead = inputStream?.read(typeBuffer) ?: -1
//                    if (typeRead == -1) break
//
//                    when (typeBuffer[0]) {
//                        0x01.toByte() -> { // Text message
//                            Log.d("BluetoothConnection", "received type: Text Message" )
//                            val textBuffer = ByteArray(1024)
//                            val len = inputStream?.read(textBuffer) ?: -1
//                            if (len > 0) {
//                                val message = String(textBuffer, 0, len)
//
//                                Log.d("data flow in:", message )
//                                withContext(Dispatchers.Main) {
//                                    incomingMessagesStreamHandler?.sendIncomingMessage(message)
//                                }
//                            }
//                        }
//
//                        0x02.toByte() -> { // File transfer
//                            // Read 4-byte file size
//                            Log.d("BluetoothConnection", "received type: File transfer" )
//                            var totalSizeRead = 0
//                            while (totalSizeRead < 4) {
//                                val read = inputStream?.read(sizeBuffer, totalSizeRead, 4 - totalSizeRead) ?: -1
//                                if (read == -1) throw IOException("Stream closed while reading file size")
//                                totalSizeRead += read
//                            }
//                            val fileSize = ByteBuffer.wrap(sizeBuffer).order(ByteOrder.BIG_ENDIAN).int
//
//                            if (fileSize > 2 * 1024 * 1024) {
//                                throw IOException("File too large: $fileSize")
//                            }
//
//                            val fileBuffer = ByteArray(fileSize)
//                            var readTotal = 0
//                            while (readTotal < fileSize) {
//                                val read = inputStream?.read(fileBuffer, readTotal, fileSize - readTotal) ?: -1
//                                if (read == -1) throw IOException("Connection lost during file read")
//                                readTotal += read
//                            }
//
//                            val actualPayload = fileBuffer.copyOfRange(1, fileBuffer.size) // remove 0x02 prefix
//                            val base64 = String(actualPayload, Charsets.UTF_8) // now it's exactly what Flutter sent
//                            Log.d("data flow in:", base64 )
//                            withContext(Dispatchers.Main) {
//                                incomingMessagesStreamHandler?.sendIncomingMessage(base64)
//
//                            }
//                        }
//
//                        else -> {
//                            Log.w("BluetoothConnection", "Unknown message type: ${typeBuffer[0]}")
//                        }
//                    }
//                }
//
//            } catch (e: IOException) {
//                Log.e("BluetoothConnection", "Error receiving file", e)
//                withContext(Dispatchers.Main) {
//                    connectionStateStreamHandler?.notifyDisconnected()
//                    onLostConnection()
//                }
//            } finally {
//                isRunning = false
//            }
//        }
//    }

    fun write(data: String) {
        try {
            val dataBytes = data.toByteArray()
            val dataSize = dataBytes.size

            // Send the size of the string as an integer (4 bytes)
            val sizeBytes = ByteBuffer.allocate(4).putInt(dataSize).array()
            outputStream?.write(sizeBytes)

            // Send the string data
            outputStream?.write(dataBytes)

            outputStream?.flush() // Ensure data is sent

            Log.d("BluetoothConnection", "Sent string of size: $dataSize")
        } catch (e: IOException) {
            Log.e("BluetoothConnection", "Write failed", e)
            connectionStateStreamHandler?.notifyDisconnected()
        }
    }



//    fun write(data: String) {
//        try {
//            outputStream?.write(data.toByteArray())
//            Log.d("BluetoothConnection", "Sent: $data")
//        } catch (e: IOException) {
//            Log.e("BluetoothConnection", "Write failed", e)
//            connectionStateStreamHandler?.notifyDisconnected()
//        }
//    }

//    fun write(data: String, isFile: Boolean ) {
//        Log.d("BluetoothConnection", "isFile: $isFile" )
//        try {
//            val dataBytes = data.toByteArray()
//            val message: ByteArray = if (isFile) {
//                // Prefix with 0x02 (file), then 4-byte length, then file data
//                val lengthPrefix = ByteBuffer.allocate(4).order(ByteOrder.BIG_ENDIAN).putInt(dataBytes.size).array()
//                val finalMessage = ByteArray(1 + 4 + dataBytes.size)
//                finalMessage[0] = 0x02 // file type
//                System.arraycopy(lengthPrefix, 0, finalMessage, 1, 4)
//                finalMessage
//            } else {
//                // Prefix with 0x01 (text), then text data
//                val finalMessage = ByteArray(1 + dataBytes.size)
//                finalMessage[0] = 0x01 // text type
//                System.arraycopy(dataBytes, 0, finalMessage, 1, dataBytes.size)
//                finalMessage
//            }
//            Log.d( "data flow out:", "$message")
//            outputStream?.write(message)
//            Log.d("BluetoothConnection", "Sent (${if (isFile) "file" else "text"}): ${data.take(100)}")
//        } catch (e: IOException) {
//            Log.e("BluetoothConnection", "Write failed", e)
//            connectionStateStreamHandler?.notifyDisconnected()
//        }
//    }

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

    // Helper function to determine if it's a short message
    private fun isShortMessage(data: String): Boolean {
        // Implement logic to differentiate short messages (e.g., based on length or a special marker)
        return data.length < 100 // Example threshold
    }
}
