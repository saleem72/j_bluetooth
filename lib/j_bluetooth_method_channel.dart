import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/bluetooth_connection_state.dart';
import 'package:j_bluetooth/models/connected_device.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';
import 'package:j_bluetooth/models/jafra_error.dart';

import 'helpers/managed_stream_controller.dart';
import 'j_bluetooth_platform_interface.dart';

const String _logName = "MethodChannelJBluetooth";

/// An implementation of [JBluetoothPlatform] that uses method channels.
class MethodChannelJBluetooth extends JBluetoothPlatform {
  bool _isDisposed = false;

  @visibleForTesting
  final methodChannel = const MethodChannel(_BluetoothKeys.channelName);

  final EventChannel _adapterStateChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.adapterStateChannelName}');
  late final ManagedStreamController<BluetoothAdapterState>
      _adapterStateManagedController;
  late final StreamController<BluetoothAdapterState> _adapterStateController;

  final EventChannel _discoveryStateChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.isDiscoveringChannelName}');
  late final ManagedStreamController<bool> _discoveryStateManagedController;
  late StreamController<bool> _discoveryStateController;

  final EventChannel _deviceFoundChannel = const EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.discoveryChannelName}');
  late final ManagedStreamController<JafraBluetoothDevice>
      _deviceFoundManagedController;
  late StreamController<JafraBluetoothDevice> _deviceFoundController;

  static const EventChannel _connectionStateChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.connectionStateChannelName}');
  late final ManagedStreamController<BluetoothConnectionState>
      _connectionStateManagedController;
  late StreamController<BluetoothConnectionState> _connectionStateController;

  static const _incomingMessagesChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.inComingChannelName}');
  late final ManagedStreamController<String> _incomingMessagesManagedController;
  late StreamController<String> _incomingMessagesController;

  static const _aclConnectionChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.aclChannelName}');
  late final ManagedStreamController<ConnectedDevice>
      _aclConnectionManagedController;
  late StreamController<ConnectedDevice> _aclConnectionController;

  static const EventChannel _errorChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.errorChannelName}');
  late final ManagedStreamController<JafraError> _jafraErrorManagedController;
  late StreamController<JafraError> _jafraErrorController;

  static const EventChannel _serverStatusChannel = EventChannel(
      '${_BluetoothKeys.channelName}/${_BluetoothKeys.serverStatusChannelName}');
  late final ManagedStreamController<bool> _serverStatusManagedController;
  late StreamController<bool> _serverStatusController;

  void _createAdapterStateController() {
    _adapterStateManagedController =
        ManagedStreamController<BluetoothAdapterState>(
      streamFactory: () => _adapterStateChannel
          .receiveBroadcastStream()
          .map((event) => BluetoothAdapterState.fromString(event as String)),
    );

    _adapterStateController = _adapterStateManagedController.create();
  }

  _logClosingControllerError(
    String controller,
    Object error,
  ) {
    log('Error disposing $controller', error: error, name: _logName);
  }

  Future<void> _disposeAdapterStateController() async {
    try {
      await _adapterStateManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('adapterStateManagedController', e);
    }

    try {
      await _adapterStateController.close();
    } catch (e) {
      _logClosingControllerError('adapterStateController', e);
    }
  }

  void _createDiscoveryStateController() {
    _discoveryStateManagedController = ManagedStreamController(
      streamFactory: () =>
          _discoveryStateChannel.receiveBroadcastStream().map((event) {
        log(event.toString(), name: "MethodChannelJafraBluetooth");
        if (event == true) {
          return true;
        }
        return false;
      }),
    );

    _discoveryStateController = _discoveryStateManagedController.create();
  }

  Future<void> _disposeDiscoveryStateController() async {
    try {
      await _discoveryStateManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('discoveryStateManagedController', e);
    }
    try {
      await _discoveryStateController.close();
    } catch (e) {
      _logClosingControllerError('discoveryStateController', e);
    }
  }

  void _createDeviceFoundController() {
    _deviceFoundManagedController =
        ManagedStreamController<JafraBluetoothDevice>(
      streamFactory: () => _deviceFoundChannel
          .receiveBroadcastStream()
          .map((event) => JafraBluetoothDevice.fromMap(event)),
    );

    _deviceFoundController = _deviceFoundManagedController.create();
  }

  Future<void> _disposeDeviceFoundController() async {
    try {
      await _deviceFoundManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('deviceFoundManagedController', e);
    }
    try {
      await _deviceFoundController.close();
    } catch (e) {
      _logClosingControllerError('deviceFoundController', e);
    }
  }

  void _createConnectionStateController() {
    _connectionStateManagedController =
        ManagedStreamController<BluetoothConnectionState>(
      streamFactory: () => _connectionStateChannel
          .receiveBroadcastStream()
          .map((event) => BluetoothConnectionState.fromMap(event)),
    );

    _connectionStateController = _connectionStateManagedController.create();
  }

  Future<void> _disposeConnectionStateController() async {
    try {
      await _connectionStateManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('connectionStateManagedController', e);
    }
    try {
      await _connectionStateController.close();
    } catch (e) {
      _logClosingControllerError('connectionStateController', e);
    }
  }

  void _createIncomingMessagesController() {
    _incomingMessagesManagedController = ManagedStreamController(
      streamFactory: () =>
          _incomingMessagesChannel.receiveBroadcastStream().map((event) {
        log(event.toString(), name: '_incomingChannel');
        return event.toString();
      }),
    );

    _incomingMessagesController = _incomingMessagesManagedController.create();
  }

  Future<void> _disposeIncomingMessagesController() async {
    try {
      await _incomingMessagesManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('incomingMessagesManagedController', e);
    }
    try {
      await _incomingMessagesController.close();
    } catch (e) {
      _logClosingControllerError('incomingMessagesController', e);
    }
  }

  void _createAclConnectionController() {
    _aclConnectionManagedController = ManagedStreamController<ConnectedDevice>(
      streamFactory: () =>
          _aclConnectionChannel.receiveBroadcastStream().map((event) {
        log(event.toString(), name: '_aclChannel');
        return ConnectedDevice.fromMap(event);
      }),
    );

    _aclConnectionController = _aclConnectionManagedController.create();
  }

  Future<void> _disposeAclConnectionController() async {
    try {
      _aclConnectionManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('aclConnectionManagedController', e);
    }
    try {
      _aclConnectionController.close();
    } catch (e) {
      _logClosingControllerError('aclConnectionController', e);
    }
  }

  void _createJafraErrorController() {
    _jafraErrorManagedController = ManagedStreamController<JafraError>(
      streamFactory: () => _errorChannel.receiveBroadcastStream().map((event) {
        if (event is Map<String, dynamic>) {
          return JafraError.fromMap(event);
        }
        return JafraError.fromMap({});
      }),
    );

    _jafraErrorController = _jafraErrorManagedController.create();
  }

  Future<void> _disposeJafraErrorController() async {
    try {
      await _jafraErrorManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('jafraErrorManagedController', e);
    }
    try {
      await _jafraErrorController.close();
    } catch (e) {
      _logClosingControllerError('jafraErrorController', e);
    }
  }

  void _createServerStatusController() {
    _serverStatusManagedController = ManagedStreamController<bool>(
      streamFactory: () => _serverStatusChannel
          .receiveBroadcastStream()
          .map((event) => event is Map ? event["status"] : false),
    );

    _serverStatusController = _serverStatusManagedController.create();
  }

  Future<void> _disposeServerStatusController() async {
    try {
      await _serverStatusManagedController.dispose();
    } catch (e) {
      _logClosingControllerError('serverStatusManagedController', e);
    }
    try {
      await _serverStatusController.close();
    } catch (e) {
      _logClosingControllerError('serverStatusController', e);
    }
  }

  MethodChannelJBluetooth() {
    _createAdapterStateController();
    _createDiscoveryStateController();
    _createDeviceFoundController();
    _createConnectionStateController();
    _createIncomingMessagesController();
    _createAclConnectionController();
    _createJafraErrorController();
    _createServerStatusController();
  }

  Future<void> _cleanMainChannel() async {
    try {
      await methodChannel.invokeMethod(_BluetoothKeys.dispose);
    } catch (e) {
      log('Error cleaning main channel', error: e, name: _logName);
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    await _cleanMainChannel();
    await _disposeAdapterStateController();
    await _disposeDiscoveryStateController();
    await _disposeDeviceFoundController();
    await _disposeConnectionStateController();
    await _disposeIncomingMessagesController();
    await _disposeAclConnectionController();
    await _disposeJafraErrorController();
    await _disposeServerStatusController();
  }

  @override
  Future<String?> get adapterAddress async {
    try {
      return await methodChannel
          .invokeMethod<String>(_BluetoothKeys.getAddress);
    } catch (e, stackTrace) {
      log(
        'Failed to get adapter address',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return null;
    }
  }

  @override
  Future<String?> get adapterName async {
    try {
      return await methodChannel.invokeMethod<String>(_BluetoothKeys.getName);
    } catch (e, stackTrace) {
      log(
        'Failed to get adapter name',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return null;
    }
  }

  @override
  Future<bool> get isAvailable async {
    try {
      return (await methodChannel
              .invokeMethod<bool>(_BluetoothKeys.isAvailable)) ??
          false;
    } catch (e, stackTrace) {
      log(
        'Failed to get adapter availability',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return false;
    }
  }

  @override
  Future<bool> get isEnabled async {
    try {
      return (await methodChannel
              .invokeMethod<bool>(_BluetoothKeys.isEnabled)) ??
          false;
    } catch (e, stackTrace) {
      log(
        'Failed to get adapter isEnabled',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return false;
    }
  }

  @override
  Future<BluetoothAdapterState> get state async {
    try {
      final data = await methodChannel.invokeMethod(_BluetoothKeys.getState);
      final aState = BluetoothAdapterState.fromCode(data);
      return aState;
    } catch (e, stackTrace) {
      log(
        'Failed to get adapter state',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return BluetoothAdapterState.unknown;
    }
  }

  @override
  Future<void> startDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.startDiscovery);

  @override
  Future<void> stopDiscover() async =>
      await methodChannel.invokeMethod(_BluetoothKeys.stopDiscovery);

  @override
  Future<void> sendMessage(String message) async {
    try {
      await methodChannel.invokeMethod(_BluetoothKeys.sendMessage, {
        'message': message,
      });
    } catch (e, stackTrace) {
      log(
        'Failed to send message',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return;
    }
  }

  @override
  Future<void> startServer() async {
    try {
      await methodChannel.invokeMethod(_BluetoothKeys.startServer);
    } catch (e, stackTrace) {
      log(
        'Failed to start bluetooth server',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return;
    }
  }

  @override
  Future<void> connectToServer(JafraBluetoothDevice device) async {
    try {
      final address = device.address;
      await methodChannel.invokeMethod(_BluetoothKeys.connectToServer, {
        'address': address,
      });
    } catch (e, stackTrace) {
      log(
        'Failed to connect to server',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return;
    }
  }

  @override
  Future<List<JafraBluetoothDevice>> pairedDevices() async {
    try {
      final data =
          await methodChannel.invokeMethod(_BluetoothKeys.pairedDevices);
      if (data is List) {
        final devices =
            data.map((e) => JafraBluetoothDevice.fromMap(e)).toList();
        return devices;
      }
      return [];
    } catch (e, stackTrace) {
      log(
        'Failed to get paired devices',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return [];
    }
  }

  @override
  Future<void> openSettings() async {
    try {
      methodChannel.invokeMethod(_BluetoothKeys.openSettings);
    } catch (e, stackTrace) {
      log(
        'Failed to open bluetooth setting',
        error: e,
        stackTrace: stackTrace,
        name: _logName,
      );
      return;
    }
  }

  @override
  Stream<JafraError> pluginErrors() => _jafraErrorController.stream;

  @override
  Stream<BluetoothAdapterState> adapterState() {
    return _adapterStateController.stream;
  }

  @override
  Stream<JafraBluetoothDevice> onDevice() {
    return _deviceFoundController.stream;
  }

  @override
  Stream<bool> isDiscovering() {
    return _discoveryStateController.stream;
  }

  @override
  Stream<BluetoothConnectionState> connectionState() {
    return _connectionStateController.stream;
  }

  @override
  Stream<String> incomingMessages() => _incomingMessagesController.stream;

  @override
  Stream<ConnectedDevice> connectedDevice() {
    return _aclConnectionController.stream;
  }

  @override
  Stream<bool> serverStatus() {
    return _serverStatusController.stream;
  }
}

abstract class _BluetoothKeys {
  static const String channelName = 'j_bluetooth';
  static const String discoveryChannelName = 'discovery';
  static const String adapterStateChannelName = 'adapter_state';
  static const String isDiscoveringChannelName = 'is_discovering';
  static const String connectionStateChannelName = 'connection_state';
  static const String inComingChannelName = 'incoming';
  static const String errorChannelName = 'error';
  static const String serverStatusChannelName = "serverStatus";

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
  static const String dispose = 'dispose';
}
