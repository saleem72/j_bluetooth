import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/bluetooth_connection_state.dart';
import 'package:j_bluetooth/models/connected_device.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';

import 'j_bluetooth_platform_interface.dart';

/// An implementation of [JBluetoothPlatform] that uses method channels.
class MethodChannelJBluetooth extends JBluetoothPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel(_BluetoothKeys.channelName);

  final EventChannel _adapterStateChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.adapterStateChannelName}');
  late StreamSubscription<BluetoothAdapterState> _adapterStateSubscription;
  late StreamController<BluetoothAdapterState> _adapterStateController;

  final EventChannel _discoveryStateChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.isDiscoveringChannelName}');
  late StreamSubscription<bool> _discoveryStateSubscription;
  late StreamController<bool> _discoveryStateController;

  final EventChannel _deviceFoundChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.discoveryChannelName}');
  late StreamController<JafraBluetoothDevice> _deviceFoundController;
  late StreamSubscription<JafraBluetoothDevice> _deviceFoundSubscription;

  static const _incomingMessagesChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.inComingChannelName}');
  late StreamController<String> _incomingMessagesController;
  StreamSubscription<dynamic>? _incomingMessagesSubscription;

  static const _aclConnectionChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.aclChannelName}');
  late StreamController<ConnectedDevice> _aclConnectionController;
  StreamSubscription<dynamic>? _aclConnectionSubscription;

  static const EventChannel _connectionStateChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.connectionStateChannelName}');
  late StreamController<BluetoothConnectionState> _connectionStateController;
  StreamSubscription<dynamic>? _connectionStateSubscription;

  MethodChannelJBluetooth() {
    _adapterStateController = StreamController.broadcast(
      onCancel: () {
        // `cancelDiscovery` happens automatically by platform code when closing event sink
        _adapterStateSubscription.cancel();
      },
    );
    _discoveryStateController = StreamController.broadcast(
      onCancel: () {
        // `cancelDiscovery` happens automatically by platform code when closing event sink
        _discoveryStateSubscription.cancel();
      },
    );

    _deviceFoundController = StreamController.broadcast(
      onCancel: () {
        _deviceFoundSubscription.cancel();
      },
    );

    _connectionStateController = StreamController.broadcast(
      onCancel: () {
        _connectionStateSubscription?.cancel();
      },
    );

    _incomingMessagesController = StreamController.broadcast(
      onCancel: () {
        _incomingMessagesSubscription?.cancel();
      },
    );

    _aclConnectionController = StreamController.broadcast(
      onCancel: () {
        _aclConnectionSubscription?.cancel();
      },
    );

    _adapterStateSubscription = _adapterStateChannel
        .receiveBroadcastStream()
        .map((event) => BluetoothAdapterState.fromString(event as String))
        .listen(
          _adapterStateController.add,
          onError: _adapterStateController.addError,
          onDone: _adapterStateController.close,
        );

    _discoveryStateSubscription =
        _discoveryStateChannel.receiveBroadcastStream().map((event) {
      log(event.toString(), name: "MethodChannelJafraBluetooth");
      if (event == true) {
        return true;
      }
      return false;
    }).listen(
      _discoveryStateController.add,
      onError: _discoveryStateController.addError,
      onDone: _discoveryStateController.close,
    );

    _deviceFoundSubscription = _deviceFoundChannel
        .receiveBroadcastStream()
        .map((event) => JafraBluetoothDevice.fromMap(event))
        .listen(
          _deviceFoundController.add,
          onError: _deviceFoundController.addError,
          onDone: _deviceFoundController.close,
        );

    _incomingMessagesSubscription =
        _incomingMessagesChannel.receiveBroadcastStream().map((event) {
      log(event.toString(), name: '_incomingChannel');
      return event.toString();
    }).listen(
      _incomingMessagesController.add,
      onError: _incomingMessagesController.addError,
      onDone: _incomingMessagesController.close,
    );

    _aclConnectionSubscription =
        _aclConnectionChannel.receiveBroadcastStream().map((event) {
      log(event.toString(), name: '_aclChannel');
      return ConnectedDevice.fromMap(event);
    }).listen(
      _aclConnectionController.add,
      onError: _aclConnectionController.addError,
      onDone: _aclConnectionController.close,
    );

    _connectionStateSubscription = _connectionStateChannel
        .receiveBroadcastStream()
        .map((event) => BluetoothConnectionState.fromMap(event))
        .listen(
          _connectionStateController.add,
          onError: _connectionStateController.addError,
          onDone: _connectionStateController.close,
        );
  }

  @override
  Future<void> dispose() async {
    // await methodChannel.invokeMethod('dispose');
    _adapterStateSubscription.cancel();
    _discoveryStateController.close();

    _discoveryStateSubscription.cancel();
    _discoveryStateController.close();

    _deviceFoundSubscription.cancel();
    _deviceFoundController.close();

    _incomingMessagesSubscription?.cancel();
    _incomingMessagesController.close();

    _aclConnectionSubscription?.cancel();
    _aclConnectionController.close();

    _connectionStateSubscription?.cancel();
    _connectionStateController.close();
  }

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
    return _adapterStateController.stream;
  }

  @override
  Stream<JafraBluetoothDevice> onDevice() {
    return _deviceFoundController.stream;
  }

  @override
  Future<void> startDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.startDiscovery);

  @override
  Future<void> stopDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.stopDiscovery);

  @override
  Stream<bool> isDiscovering() {
    return _discoveryStateController.stream;
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
    return _connectionStateController.stream;
  }

  @override
  Future<void> connectToServer(JafraBluetoothDevice device) async {
    final address = device.address;
    await methodChannel.invokeMethod(_BluetoothKeys.connectToServer, {
      'address': address,
    });
  }

  @override
  Stream<String> incomingMessages() => _incomingMessagesController.stream;

  @override
  Future<List<JafraBluetoothDevice>> pairedDevices() async {
    final data = await methodChannel.invokeMethod(_BluetoothKeys.pairedDevices);
    if (data is List) {
      final devices = data.map((e) => JafraBluetoothDevice.fromMap(e)).toList();
      return devices;
    }
    return [];
  }

  @override
  Stream<ConnectedDevice> connectedDevice() {
    return _aclConnectionController.stream;
  }

  @override
  Future<void> openSettings() async {
    methodChannel.invokeMethod(_BluetoothKeys.openSettings);
  }
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
  static const String openSettings = 'openSettings';
  static const String getState = 'getState';
  static const String getAddress = 'getAddress';
  static const String getName = 'getName';
  static const String startDiscovery = 'startDiscovery';
  static const String stopDiscovery = 'stopDiscovery';
  static const String startServer = 'startServer';
  static const String connectToServer = 'connectToServer';
  // static const String pairDevice = 'pairDevice';
  static const String sendMessage = 'sendMessage';

  static const String pairedDevices = 'pairedDevices';
  static const String aclChannelName = 'acl_connection';
}
