// ignore_for_file: public_member_api_docs, sort_constructors_first
//

import 'package:j_bluetooth/models/connected_device.dart';

class BluetoothConnectionState {
  final String? address;
  final String? name;
  final bool isConnected;
  final String? error;

  BluetoothConnectionState({
    this.address,
    this.name,
    required this.isConnected,
    this.error,
  });

  factory BluetoothConnectionState.fromMap(dynamic map) =>
      BluetoothConnectionState(
          address: map["address"],
          name: map["name"],
          isConnected: map["isConnected"],
          error: map["error"]);

  ConnectedDevice? get connectedDevice {
    if (!isConnected) {
      return null;
    }

    if (address == null) {
      return null;
    }

    if (name == null) {
      return null;
    }

    return ConnectedDevice(
      address: address!,
      name: name!,
      isConnected: isConnected,
    );
  }

  @override
  String toString() {
    return 'BluetoothConnectionState(address: $address, name: $name, isConnected: $isConnected, error: $error)';
  }
}
