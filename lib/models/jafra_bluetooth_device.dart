//

import 'package:equatable/equatable.dart';
import 'package:j_bluetooth/models/BluetoothDeviceMajorType.dart';
import 'package:j_bluetooth/models/BluetoothDeviceMinorType.dart';

class JafraBluetoothDevice extends Equatable {
  final String? name;
  final String address;

  final int deviceClass;
  final int majorDeviceClass;
  final int minorDeviceClass;
  final int rssi;

  final BluetoothDeviceMajorType majorCategory;
  final BluetoothDeviceMinorType? minorCategory;

  const JafraBluetoothDevice({
    this.name,
    required this.address,
    required this.deviceClass,
    required this.majorDeviceClass,
    required this.minorDeviceClass,
    required this.majorCategory,
    required this.minorCategory,
    required this.rssi,
  });

  factory JafraBluetoothDevice.fromMap(dynamic data) {
    return JafraBluetoothDevice(
      name: data["name"],
      address: data["address"],
      deviceClass: data["deviceClass"],
      majorDeviceClass: data["majorDeviceClass"],
      minorDeviceClass: data["minorDeviceClass"],
      majorCategory: data['majorDeviceClass'] is int
          ? BluetoothDeviceMajorType.fromDeviceClass(data['majorDeviceClass'])
          : BluetoothDeviceMajorType.unCategorized,
      minorCategory: data['deviceClass'] is int
          ? BluetoothDeviceMinorType.fromFullClass(data['deviceClass'])
          : BluetoothDeviceMinorType.unknownDevice,
      rssi: data["rssi"],
    );
  }

  @override
  String toString() => 'JafraBluetoothDevice(name: $name, address: $address)';

  @override
  List<Object?> get props => [address];
}
