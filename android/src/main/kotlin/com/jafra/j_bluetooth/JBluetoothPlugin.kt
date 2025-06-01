package com.jafra.j_bluetooth

import android.Manifest
import android.annotation.SuppressLint
import android.app.Activity
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.BluetoothSocket
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.jafra.j_bluetooth.data.helpers.BluetoothClient
import com.jafra.j_bluetooth.data.helpers.BluetoothConnection
import com.jafra.j_bluetooth.data.helpers.BluetoothServer
import com.jafra.j_bluetooth.data.mappers.toJafraBluetoothDevice
import com.jafra.j_bluetooth.data.mappers.toMap
import com.jafra.j_bluetooth.data.receivers.AclConnectionReceiver
import com.jafra.j_bluetooth.data.receivers.BluetoothAdapterStateReceiver
import com.jafra.j_bluetooth.data.receivers.BondingStateReceiver
import com.jafra.j_bluetooth.data.receivers.DeviceFoundReceiver
import com.jafra.j_bluetooth.data.receivers.DiscoveryStateReceiver
import com.jafra.j_bluetooth.data.streams.ConnectionStateStreamHandler
import com.jafra.j_bluetooth.data.streams.ErrorStreamHandler
import com.jafra.j_bluetooth.data.streams.IncomingMessagesStreamHandler
import com.jafra.j_bluetooth.data.streams.ServerStatusStreamHandler
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

/** JBluetoothPlugin */
class JBluetoothPlugin: FlutterPlugin, MethodCallHandler, ActivityAware,
  PluginRegistry.RequestPermissionsResultListener {


  companion object {
    const val TAG = "JBluetoothPlugin"
    const val REQUEST_BLUETOOTH_PERMISSIONS = 1001
    const val channelName = "j_bluetooth"
    const val discoveryChannelName = "discovery"
    const val adapterStateChannelName = "adapter_state"
    const val isDiscoveringChannelName = "is_discovering"
    const val connectionStateChannelName = "connection_state"
    const val inComingChannelName = "incoming"
    const val aclChannelName = "acl_connection"
    const val errorChannelName = "error"
    const val serverStatusChannelName = "serverStatus"

    const val isAvailable = "isAvailable"
    const val isOn = "isOn"
    const val isEnabled = "isEnabled"
    const val openSettings = "openSettings"
    const val getState = "getState"
    const val getAddress = "getAddress"
    const val getName = "getName"
    const val startDiscovery = "startDiscovery"
    const val stopDiscovery = "stopDiscovery"
    const val startServer = "startServer"
    const val stopServer = "stopServer"
    const val connectToServer = "connectToServer"
    const val pairDevice = "pairDevice"
    const val sendMessage = "sendMessage"
    const val pairedDevices = "pairedDevices"
    const val dispose = "dispose"
//    const val uuidString = "00001101-0000-1000-8000-00805F9B34FB"

//    const val ensurePermissions = "ensurePermissions"
  }

  private lateinit var bluetoothAdapter: BluetoothAdapter
  private lateinit var context: Context
  private var activity: Activity? = null

  private lateinit var channel: MethodChannel

  private  var deviceFoundChannel: EventChannel? = null
  private  var adapterStateChannel: EventChannel? = null
  private  var discoveryStateChannel: EventChannel? = null
  private  var connectionStateChannel: EventChannel? = null
  private  var incomingMessagesChannel: EventChannel? = null
  private var aclConnectionChannel: EventChannel? = null
  private var errorChannel: EventChannel? = null
  private var serverStatusChannel: EventChannel? = null


  private  var deviceFoundReceiver: DeviceFoundReceiver? = null
  private  var adapterStateReceiver: BluetoothAdapterStateReceiver? = null
  private  var discoveryStateReceiver: DiscoveryStateReceiver? = null
  private  var connectionStateStreamHandler: ConnectionStateStreamHandler? = null
  private var aclConnectionReceiver: AclConnectionReceiver? = null
  private var incomingMessagesStreamHandler: IncomingMessagesStreamHandler? = null
  private var errorStreamHandler: ErrorStreamHandler? = null
  private var serverStatusStreamHandler: ServerStatusStreamHandler? = null

  private var connectionHandler: BluetoothConnection? = null
  private var bondingStateReceiver: BondingStateReceiver? = null

  private var pendingOnGranted: (() -> Unit)? = null
  private var pendingOnDenied: ((String) -> Unit)? = null

  private var bluetoothSocket: BluetoothSocket? = null
  private lateinit var messenger: FlutterPlugin.FlutterPluginBinding

  private var server: BluetoothServer? = null





  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {


    messenger = flutterPluginBinding
    context = flutterPluginBinding.applicationContext
    bluetoothAdapter = getBluetoothAdapter(context)
    channel = MethodChannel(
      flutterPluginBinding.binaryMessenger,
      channelName
    )
    channel.setMethodCallHandler(this)

    createDeviceFoundChannel(flutterPluginBinding)

    createAdapterStateChannel(flutterPluginBinding)

    createDiscoveryStateChannel(flutterPluginBinding)

    bondingStateReceiver = BondingStateReceiver(context)

    createConnectionStateChannel(flutterPluginBinding)

    createIncomingMessagesChannel(flutterPluginBinding)

    createAclConnectionChannel(flutterPluginBinding)
    createErrorChannel(flutterPluginBinding)
    createServerStatusChannel(flutterPluginBinding)

    Log.d(TAG, "onAttachedToEngine: JafraBluetoothPlugin was created")
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    server = null
    closeConnection()
    cleanDiscoveryStateChannel()
    cleanConnectionStateChannel()
    cleanIncomingMessagesChannel()
    cleanDeviceFoundChannel()
    cleanAdapterStateChannel()
    cleanAclConnectionChannel()
    cleanErrorChannel()
    cleanServerStatusChannel()
  }



  @SuppressLint("MissingPermission")
  override fun onMethodCall(call: MethodCall, result: Result) {
    when (call.method) {

      isAvailable -> {
        return result.success(true)
      }


      isOn, isEnabled -> {
        result.success(bluetoothAdapter.isEnabled)
      }


      openSettings -> {
        val intent = Intent(Settings.ACTION_BLUETOOTH_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        ContextCompat.startActivity(
          context,
          intent,
          null,
        )

        result.success(null)
      }

      getState -> {
        ensureBluetoothPermissions(


          onGranted = {

            val aState = bluetoothAdapter.state
            result.success(aState)
          },
          onDenied = { error ->
            Log.d(TAG, "getState: $error")
            result.success(null)
          }
        )
      }


      getName -> {
        ensureBluetoothPermissions(


          onGranted = {

            val name = bluetoothAdapter.name
            result.success(name)
          },
          onDenied = { error ->
            Log.d(TAG, "getName: $error")
            result.success(null)
          }
        )
      }

      getAddress -> {
        result.success("mac address is hidden by system")
      }

      startDiscovery -> {
        Log.d(TAG, "onMethodCall: startDiscovery")
        deviceFoundReceiver?.startDiscovery()
      }

      stopDiscovery -> {
        Log.d(TAG, "onMethodCall: stopDiscovery")
        deviceFoundReceiver?.stopDiscovery()
      }

      pairedDevices -> {
       val devices =  bluetoothAdapter.bondedDevices.map { it.toJafraBluetoothDevice(null).toMap() }
        result.success(devices)
      }

      pairDevice -> {
        val address = call.argument<String>("address")
        if (address == null) {
          result.error("INVALID_ARGUMENT", "Device address is null", null)
          return
        }

        val device = bluetoothAdapter.getRemoteDevice(address)

        bondingStateReceiver?.pairDevice(device, object : BondingStateReceiver.PairingCallback {
          override fun onBonding(device: BluetoothDevice) {
            Log.d("Plugin", "Bonding started...")
            // Optional: notify Dart side
          }

          override fun onBonded(device: BluetoothDevice) {
            Log.d("Plugin", "Bonded successfully")
            bondingStateReceiver?.cleanup()
            result.success("bonded")
          }

          override fun onBondingFailed(device: BluetoothDevice) {
            Log.d("Plugin", "Bonding failed")
            bondingStateReceiver?.cleanup()
            result.error("BONDING_FAILED", "Could not pair with ${device.name}", null)
          }
        })
      }

      startServer -> {
        if (bluetoothAdapter.isDiscovering) {
          bluetoothAdapter.cancelDiscovery()
        }
        val seconds: Int? = call.argument("seconds")
        val timeoutMs = seconds?.times(1000) ?: 15000
        server = BluetoothServer(bluetoothAdapter, serverStatusStreamHandler)
        server?.startServer(
          timeoutMs,
          onConnected = { socket, remoteDevice ->
            // Save socket and start I/O stream handling
            Log.d(TAG, "Server accepted connection")
            bluetoothSocket = socket
            connectionHandler = BluetoothConnection(
              socket,
              connectionStateStreamHandler,
              incomingMessagesStreamHandler,
              onLostConnection = {
                closeConnection()
              }
            )
            connectionHandler?.start()
            connectionStateStreamHandler?.notifyConnected(remoteDevice)
          },
          onError = { e ->
            connectionStateStreamHandler?.notifyDisconnected()
            connectionStateStreamHandler?.notifyError(e.message ?: "Unknown Error")
            closeConnection()
          }
        )
        result.success("server_started")
      }

      stopServer -> {
        server?.stopServer()
      }

      connectToServer -> {
        if (bluetoothAdapter.isDiscovering) {
          bluetoothAdapter.cancelDiscovery()
        }
        val address = call.argument<String>("address")
        val seconds: Int? = call.argument("seconds")
        val timeoutMs = seconds?.times(1000) ?: 15000

        if (address == null) {
          result.error("INVALID_ARGUMENT", "Device address is null", null)
          return
        }
        val device = bluetoothAdapter.getRemoteDevice(address)
        val client = BluetoothClient(device, serverStatusStreamHandler)

        client.connect(
          timeoutMs,
          onConnected = { socket, remoteDevice ->
            Log.d(TAG, "Client connected to server")
            // Save socket and start I/O stream handling
            bluetoothSocket = socket
            connectionHandler = BluetoothConnection(
              socket,
              connectionStateStreamHandler,
              incomingMessagesStreamHandler,
              onLostConnection = {
                closeConnection()
              }
            )
            connectionHandler?.start()
            connectionStateStreamHandler?.notifyConnected(remoteDevice)
          },
          onError = { e ->
            Log.e(TAG, "Client connection failed: ${e.message}")
            connectionStateStreamHandler?.notifyDisconnected()
            connectionStateStreamHandler?.notifyError(e.message ?: "Unknown Error")
            closeConnection()
          }
        )
        result.success("connecting")
      }

      sendMessage -> {
        val message = call.argument<String>("message")
        connectionHandler?.write(message ?: "")
      }

      dispose -> {
        closeConnection()
        result.success(null)
      }

      else -> result.notImplemented()
    }
  }

  override fun onRequestPermissionsResult(
    requestCode: Int, permissions: Array<out String>, grantResults: IntArray
  ): Boolean {
    if (requestCode == REQUEST_BLUETOOTH_PERMISSIONS) {
      val allGranted = grantResults.all { it == PackageManager.PERMISSION_GRANTED }
      if (allGranted) {
        pendingOnGranted?.invoke()
      } else {
        pendingOnDenied?.invoke("One or more Bluetooth permissions denied.")
      }
      pendingOnGranted = null
      pendingOnDenied = null
      return true
    }
    return false
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivity() {
    activity = null
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {

    activity = binding.activity
    binding.addRequestPermissionsResultListener(this)
  }

  override fun onDetachedFromActivityForConfigChanges() {

    activity = null
  }

  private fun getBluetoothAdapter(context: Context): BluetoothAdapter {
    val bluetoothManager =
      context.getSystemService(Context.BLUETOOTH_SERVICE) as? BluetoothManager
    return bluetoothManager?.adapter ?: throw IllegalStateException("Bluetooth not supported")
  }


  private fun ensureBluetoothPermissions(
    onGranted: () -> Unit,
    onDenied: ((errorMessage: String) -> Unit)? = null
  ) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
      val requiredPermissions = listOf(
        Manifest.permission.BLUETOOTH_CONNECT,
        Manifest.permission.BLUETOOTH_SCAN,
        Manifest.permission.ACCESS_FINE_LOCATION,
      )

      val missingPermissions = requiredPermissions.filter {
        ContextCompat.checkSelfPermission(context, it) != PackageManager.PERMISSION_GRANTED
      }

      if (missingPermissions.isNotEmpty()) {
        if (activity != null) {
          ActivityCompat.requestPermissions(
            activity!!,
            missingPermissions.toTypedArray(),
            REQUEST_BLUETOOTH_PERMISSIONS
          )
          pendingOnGranted = onGranted
          pendingOnDenied = onDenied
        } else {
          onDenied?.invoke("Plugin not attached to an activity.")
        }
        return
      }
    }

    // All required permissions are already granted or not needed
    onGranted()
  }

  private fun createAclConnectionChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    aclConnectionReceiver = AclConnectionReceiver(context)
    aclConnectionChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "$channelName/$aclChannelName")
    aclConnectionChannel?.setStreamHandler(aclConnectionReceiver)
  }

  private fun cleanAclConnectionChannel() {
    aclConnectionChannel?.setStreamHandler(null)
    aclConnectionChannel = null
    aclConnectionReceiver = null
  }

  private fun createDiscoveryStateChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    discoveryStateChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$isDiscoveringChannelName"
    )
    discoveryStateReceiver = DiscoveryStateReceiver(context)
    discoveryStateChannel?.setStreamHandler(discoveryStateReceiver)
  }

  private fun cleanDiscoveryStateChannel() {
    discoveryStateChannel?.setStreamHandler(null)
    discoveryStateChannel = null
    discoveryStateReceiver = null
  }

  private fun createDeviceFoundChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    deviceFoundChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$discoveryChannelName"
    )
    deviceFoundReceiver = DeviceFoundReceiver(context, bluetoothAdapter)
    deviceFoundChannel?.setStreamHandler(deviceFoundReceiver)
  }

  private fun cleanDeviceFoundChannel() {
    deviceFoundChannel?.setStreamHandler(null)
    deviceFoundChannel = null
    deviceFoundReceiver?.stopDiscovery()
    deviceFoundReceiver = null
  }

  private fun createAdapterStateChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    adapterStateChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$adapterStateChannelName"
    )
    adapterStateReceiver = BluetoothAdapterStateReceiver(flutterPluginBinding.applicationContext)
    adapterStateChannel?.setStreamHandler(adapterStateReceiver)
  }

  private fun cleanAdapterStateChannel() {
    adapterStateChannel?.setStreamHandler(null)
    adapterStateChannel = null
    adapterStateReceiver = null
  }

  private fun createIncomingMessagesChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    incomingMessagesChannel =
      EventChannel(flutterPluginBinding.binaryMessenger, "$channelName/$inComingChannelName")
    incomingMessagesStreamHandler = IncomingMessagesStreamHandler()
    incomingMessagesChannel?.setStreamHandler(incomingMessagesStreamHandler)
  }

  private fun cleanIncomingMessagesChannel() {
    incomingMessagesChannel?.setStreamHandler(null)
    incomingMessagesChannel = null
    incomingMessagesStreamHandler = null
  }

  private fun createConnectionStateChannel(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    connectionStateChannel = EventChannel(
      flutterPluginBinding.binaryMessenger,
      "$channelName/$connectionStateChannelName"
    )
    connectionStateStreamHandler = ConnectionStateStreamHandler()
    connectionStateChannel?.setStreamHandler(connectionStateStreamHandler)
  }

  private fun cleanConnectionStateChannel() {
    connectionStateChannel?.setStreamHandler(null)
    connectionStateChannel = null
    connectionStateStreamHandler = null
  }

  private fun createErrorChannel(binding: FlutterPlugin.FlutterPluginBinding) {
    errorStreamHandler = ErrorStreamHandler()
    errorChannel = EventChannel(binding.binaryMessenger, "$channelName/$errorChannelName")
    errorChannel?.setStreamHandler(errorStreamHandler)
  }

  private fun cleanErrorChannel() {
    errorChannel?.setStreamHandler(null)
    errorChannel = null
    errorStreamHandler = null
  }

  private fun createServerStatusChannel(binding: FlutterPlugin.FlutterPluginBinding) {
    serverStatusStreamHandler = ServerStatusStreamHandler()
    serverStatusChannel = EventChannel(binding.binaryMessenger, "$channelName/$serverStatusChannelName")
    serverStatusChannel?.setStreamHandler(serverStatusStreamHandler)
  }

  private fun cleanServerStatusChannel() {
    serverStatusChannel?.setStreamHandler(null)
    serverStatusChannel = null
    serverStatusStreamHandler = null
  }

  private fun closeConnection() {
    connectionHandler?.stop()
    bluetoothSocket?.close()
    connectionHandler = null
    bluetoothSocket = null
  }

}
