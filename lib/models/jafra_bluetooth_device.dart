//

import 'package:equatable/equatable.dart';
import 'package:j_bluetooth/models/bluetooth_device_bond_status.dart';
import 'package:j_bluetooth/models/bluetooth_device_major_type.dart';
import 'package:j_bluetooth/models/bluetooth_device_minor_type.dart';

export './jafra_device_extension.dart';

class JafraBluetoothDevice extends Equatable {
  final String? name;
  final String address;

  final int deviceClass;
  final int majorDeviceClass;
  final int minorDeviceClass;
  final int rssi;
  final BluetoothDeviceBondStatus bond;

  final BluetoothDeviceMajorType majorCategory;
  final BluetoothDeviceMinorType? minorCategory;

  bool get isBond => bond == BluetoothDeviceBondStatus.bonded;

  const JafraBluetoothDevice({
    this.name,
    required this.address,
    required this.deviceClass,
    required this.majorDeviceClass,
    required this.minorDeviceClass,
    required this.majorCategory,
    required this.minorCategory,
    required this.rssi,
    required this.bond,
  });

  @override
  String toString() => 'JafraBluetoothDevice(name: $name, address: $address)';

  @override
  List<Object?> get props => [address];
}
