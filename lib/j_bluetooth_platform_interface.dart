import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'j_bluetooth_method_channel.dart';

abstract class JBluetoothPlatform extends PlatformInterface {
  /// Constructs a JBluetoothPlatform.
  JBluetoothPlatform() : super(token: _token);

  static final Object _token = Object();

  static JBluetoothPlatform _instance = MethodChannelJBluetooth();

  /// The default instance of [JBluetoothPlatform] to use.
  ///
  /// Defaults to [MethodChannelJBluetooth].
  static JBluetoothPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [JBluetoothPlatform] when
  /// they register themselves.
  static set instance(JBluetoothPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<void> dispose() async {
    throw UnimplementedError('openSettings() has not been implemented.');
  }

  Future<String?> get adapterName;

  Future<String?> get adapterAddress;

  Future<bool> get isAvailable;

  Future<bool> get isEnabled;

  Future<BluetoothAdapterState> get state;

  Future<void> startDiscover();

  Future<void> stopDiscover();

  Stream<JafraBluetoothDevice> onDevice();

  Stream<BluetoothAdapterState> discoveredDevices() {
    throw UnimplementedError('startDiscovery() has not been implemented.');
  }

  Stream<bool> isDiscovering();

  Future<void> openSettings() {
    throw UnimplementedError('openSettings() has not been implemented.');
  }

  Future<bool> ensurePermissions() {
    throw UnimplementedError('ensurePermissions() has not been implemented.');
  }
}
