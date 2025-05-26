import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';

import 'j_bluetooth_platform_interface.dart';

export './models/models.dart';
export './views/views.dart';

class JBluetooth {
  JBluetoothPlatform get singleton => JBluetoothPlatform.instance;

  Future<String?> get adapterAddress => singleton.adapterAddress;

  Future<String?> get adapterName => singleton.adapterName;

  Future<bool> get isAvailable => singleton.isAvailable;

  Future<bool> get isEnabled => singleton.isEnabled;

  Future<BluetoothAdapterState> get state => singleton.state;

  Future<void> dispose() => singleton.dispose();

  Stream<BluetoothAdapterState> discoveredDevices() {
    return singleton.discoveredDevices();
  }

  Future<void> startDiscover() async => singleton.startDiscover();

  Future<void> stopDiscover() async => singleton.stopDiscover();

  Stream<bool> isDiscovering() => singleton.isDiscovering();

  Stream<JafraBluetoothDevice> onDevice() => singleton.onDevice();
}
