//

import 'dart:io' as io;

import 'package:j_bluetooth/models/base_device_info.dart';
import 'package:j_bluetooth/models/bluetooth_adapter_state.dart';
import 'package:j_bluetooth/models/bluetooth_connection_state.dart';
import 'package:j_bluetooth/models/connected_device.dart';
import 'package:j_bluetooth/models/connecting_status.dart';
import 'package:j_bluetooth/models/ios_device_info.dart';
import 'package:j_bluetooth/models/jafra_bluetooth_device.dart';
import 'package:j_bluetooth/models/jafra_error.dart';

import 'j_bluetooth_platform_interface.dart';
import 'models/android_device_info.dart';

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

  Future<void> startServer({int? seconds}) => singleton.startServer(seconds);

  Future<void> sendMessage(String message) => singleton.sendMessage(message);

  Future<void> connectToServer(JafraBluetoothDevice device) =>
      singleton.connectToServer(device);
  Stream<String> incomingMessages() => singleton.incomingMessages();

  Future<List<JafraBluetoothDevice>> pairedDevices() =>
      singleton.pairedDevices();

  Stream<ConnectedDevice> connectedDevice() => singleton.connectedDevice();

  Future<void> openSettings() => singleton.openSettings();

  Stream<JafraError> pluginErrors() => singleton.pluginErrors();

  Stream<ConnectingStatus> serverStatus() => singleton.serverStatus();

  Future<void> endConnection() => singleton.endConnection();

  /// This information does not change from call to call. Cache it.
  AndroidDeviceInfo? _cachedAndroidDeviceInfo;

  /// Information derived from `android.os.Build`.
  ///
  /// See: https://developer.android.com/reference/android/os/Build.html
  Future<AndroidDeviceInfo> get androidInfo async =>
      _cachedAndroidDeviceInfo ??=
          AndroidDeviceInfo.fromMap((await singleton.deviceInfo()).data);

  /// This information does not change from call to call. Cache it.
  IosDeviceInfo? _cachedIosDeviceInfo;

  /// Information derived from `UIDevice`.
  ///
  /// See: https://developer.apple.com/documentation/uikit/uidevice
  Future<IosDeviceInfo> get iosInfo async => _cachedIosDeviceInfo ??=
      IosDeviceInfo.fromMap((await singleton.deviceInfo()).data);

  /// Returns device information for the current platform.
  // @override
  Future<BaseDeviceInfo> get deviceInfo async {
    if (io.Platform.isAndroid) {
      return androidInfo;
    } else if (io.Platform.isIOS) {
      return iosInfo;
    }
    // allow for extension of the plugin
    return singleton.deviceInfo();
  }
}
