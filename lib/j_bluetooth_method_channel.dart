import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/bluetooth_connection_state.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';

import 'j_bluetooth_platform_interface.dart';

/// An implementation of [JBluetoothPlatform] that uses method channels.
class MethodChannelJBluetooth extends JBluetoothPlatform {
  late StreamSubscription<BluetoothAdapterState>
      _bluetoothAdapterStateSubscription;
  late StreamController<BluetoothAdapterState> _bluetoothAdapterStateController;

  late StreamSubscription<bool> _bluetoothIsDiscoveringSubscription;
  late StreamController<bool> _bluetoothIsDiscoveringController;

  late StreamController<JafraBluetoothDevice> _bluetoothDeviceController;
  late StreamSubscription<JafraBluetoothDevice> _bluetoothDeviceSubscription;

  late StreamController<String> _incomingMessagesController;
  StreamSubscription<dynamic>? _incomingSubscription;

  late StreamController<BluetoothConnectionState>
      _bluetoothConnectionController;
  StreamSubscription<dynamic>? _connectionSubscription;

  static const _incomingChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.inComingChannelName}');

  static const EventChannel _connectionChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.connectionStateChannelName}');

  MethodChannelJBluetooth() {
    _bluetoothAdapterStateController = StreamController(
      onCancel: () {
        // `cancelDiscovery` happens automatically by platform code when closing event sink
        _bluetoothAdapterStateSubscription.cancel();
      },
    );
    _bluetoothIsDiscoveringController = StreamController(
      onCancel: () {
        // `cancelDiscovery` happens automatically by platform code when closing event sink
        _bluetoothIsDiscoveringSubscription.cancel();
      },
    );

    _bluetoothDeviceController = StreamController(
      onCancel: () {
        _bluetoothDeviceSubscription.cancel();
      },
    );

    _bluetoothConnectionController = StreamController(
      onCancel: () {
        _connectionSubscription?.cancel();
      },
    );

    _incomingMessagesController = StreamController(
      onCancel: () {
        _incomingSubscription?.cancel();
      },
    );

    _bluetoothAdapterStateSubscription = _adapterStateChannel
        .receiveBroadcastStream()
        .map((event) => BluetoothAdapterState.fromString(event as String))
        .listen(
          _bluetoothAdapterStateController.add,
          onError: _bluetoothAdapterStateController.addError,
          onDone: _bluetoothAdapterStateController.close,
        );

    _bluetoothIsDiscoveringSubscription =
        _isDiscoveringChannel.receiveBroadcastStream().map((event) {
      log(event.toString(), name: "MethodChannelJafraBluetooth");
      if (event == true) {
        return true;
      }
      return false;
    }).listen(
      _bluetoothIsDiscoveringController.add,
      onError: _bluetoothIsDiscoveringController.addError,
      onDone: _bluetoothIsDiscoveringController.close,
    );

    _bluetoothDeviceSubscription = _devicesChannel
        .receiveBroadcastStream()
        .map((event) => JafraBluetoothDevice.fromMap(event))
        .listen(
          _bluetoothDeviceController.add,
          onError: _bluetoothDeviceController.addError,
          onDone: _bluetoothDeviceController.close,
        );

    _incomingSubscription = _incomingChannel
        .receiveBroadcastStream()
        .map((event) => event.toString())
        .listen(
          _incomingMessagesController.add,
          onError: _incomingMessagesController.addError,
          onDone: _incomingMessagesController.close,
        );

    _connectionSubscription = _connectionChannel
        .receiveBroadcastStream()
        .map((event) => BluetoothConnectionState.fromString(event))
        .listen(
          _bluetoothConnectionController.add,
          onError: _bluetoothConnectionController.addError,
          onDone: _bluetoothConnectionController.close,
        );
  }

  @override
  Future<void> dispose() async {
    // await methodChannel.invokeMethod('dispose');
    _bluetoothAdapterStateSubscription.cancel();
    _bluetoothIsDiscoveringController.close();

    _bluetoothIsDiscoveringSubscription.cancel();
    _bluetoothAdapterStateController.close();
    _incomingSubscription?.cancel();
    _connectionSubscription?.cancel();
  }

  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(_BluetoothKeys.channelName);

  final EventChannel _adapterStateChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.adapterStateChannelName}');

  final EventChannel _isDiscoveringChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.isDiscoveringChannelName}');

  final EventChannel _devicesChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.discoveryChannelName}');
  @override
  Future<String?> get adapterAddress async =>
      await methodChannel.invokeMethod<String>(_BluetoothKeys.getAddress);

  @override
  Future<String?> get adapterName async =>
      await methodChannel.invokeMethod<String>(_BluetoothKeys.getName);

  @override
  Future<bool> get isAvailable async =>
      (await methodChannel.invokeMethod<bool>(_BluetoothKeys.isAvailable)) ??
      false;

  @override

  ///  Bluetooth adapter is On.
  Future<bool> get isEnabled async =>
      (await methodChannel.invokeMethod<bool>(_BluetoothKeys.isEnabled)) ??
      false;

  @override

  /// State of the Bluetooth adapter.
  Future<BluetoothAdapterState> get state async {
    final data = await methodChannel.invokeMethod(_BluetoothKeys.getState);
    final aState = BluetoothAdapterState.fromCode(data);
    return aState;
  }

  @override

  /// Starts discovery and provides stream of `BluetoothDiscoveryResult`s.
  Stream<BluetoothAdapterState> discoveredDevices() {
    return _bluetoothAdapterStateController.stream;
  }

  @override
  Stream<JafraBluetoothDevice> onDevice() {
    return _bluetoothDeviceController.stream;
  }

  @override
  Future<void> startDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.startDiscovery);

  @override
  Future<void> stopDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.stopDiscovery);

  @override
  Stream<bool> isDiscovering() {
    return _bluetoothIsDiscoveringController.stream;
  }

  @override
  Future<void> sendMessage(String message) async {
    try {
      await methodChannel.invokeMethod(_BluetoothKeys.sendMessage, {
        'message': message,
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to send message: ${e.message}');
    }
  }

  @override
  Future<void> startServer() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.startServer);

  @override
  Stream<BluetoothConnectionState> connectionState() {
    return _bluetoothConnectionController.stream;
  }

  @override
  Future<void> connectToServer() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.connectToServer);

  @override
  Stream<String> incomingMessages() => _incomingMessagesController.stream;
}

abstract class _BluetoothKeys {
  static const String channelName = 'j_bluetooth';
  static const String discoveryChannelName = 'discovery';
  static const String adapterStateChannelName = 'adapter_state';
  static const String isDiscoveringChannelName = 'is_discovering';
  static const String connectionStateChannelName = 'connection_state';
  static const String inComingChannelName = 'incoming';

  static const String isAvailable = 'isAvailable';
  // static const String isOn = 'isOn';
  static const String isEnabled = 'isEnabled';
  // static const String openSettings = 'openSettings';
  static const String getState = 'getState';
  static const String getAddress = 'getAddress';
  static const String getName = 'getName';
  static const String startDiscovery = 'startDiscovery';
  static const String stopDiscovery = 'stopDiscovery';
  static const String startServer = 'startServer';
  static const String connectToServer = 'connectToServer';
  static const String pairDevice = 'pairDevice';
  static const String sendMessage = 'sendMessage';
}
