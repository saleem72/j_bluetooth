import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/bluetooth_connection_state.dart';
import 'package:j_bluetooth/models/connected_device.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';
import 'package:j_bluetooth/models/plugin_error.dart';

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

  Stream<BluetoothAdapterState> adapterState() {
    return singleton.adapterState();
  }

  Future<void> startDiscover() async => singleton.startDiscover();

  Future<void> stopDiscover() async => singleton.stopDiscover();

  Stream<bool> isDiscovering() => singleton.isDiscovering();

  Stream<JafraBluetoothDevice> onDevice() => singleton.onDevice();
  Stream<BluetoothConnectionState> connectionState() =>
      singleton.connectionState();

  Future<void> startServer() => singleton.startServer();

  Future<void> sendMessage(String message) => singleton.sendMessage(message);

  Future<void> connectToServer(JafraBluetoothDevice device) =>
      singleton.connectToServer(device);
  Stream<String> incomingMessages() => singleton.incomingMessages();

  Future<List<JafraBluetoothDevice>> pairedDevices() =>
      singleton.pairedDevices();

  Stream<ConnectedDevice> connectedDevice() => singleton.connectedDevice();

  Future<void> openSettings() => singleton.openSettings();

  Stream<PluginError> pluginErrors() => singleton.pluginErrors();
}
