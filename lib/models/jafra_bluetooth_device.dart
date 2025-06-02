//

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:j_bluetooth/models/bluetooth_device_bond_status.dart';
import 'package:j_bluetooth/models/bluetooth_device_major_type.dart';
import 'package:j_bluetooth/models/bluetooth_device_minor_type.dart';

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
      bond: data["bond"] is String
          ? BluetoothDeviceBondStatus.fromString(data["bond"])
          : BluetoothDeviceBondStatus.unknown,
    );
  }

  @override
  String toString() => 'JafraBluetoothDevice(name: $name, address: $address)';

  @override
  List<Object?> get props => [address];

  Color get rssiColor => switch (rssi) {
        >= -35 => Colors.greenAccent.shade700,
        >= -45 => Color.lerp(Colors.greenAccent.shade700, Colors.lightGreen,
                -(rssi + 35) / 10) ??
            Colors.greenAccent.shade400,
        >= -55 =>
          Color.lerp(Colors.lightGreen, Colors.lime[600], -(rssi + 45) / 10) ??
              Colors.lightGreen.shade400,
        >= -65 =>
          Color.lerp(Colors.lime[600], Colors.amber, -(rssi + 55) / 10) ??
              Colors.lightGreen.shade400,
        >= -75 => Color.lerp(
                Colors.amber, Colors.deepOrangeAccent, -(rssi + 65) / 10) ??
            Colors.lightGreen.shade400,
        >= -85 => Color.lerp(
                Colors.deepOrangeAccent, Colors.redAccent, -(rssi + 75) / 10) ??
            Colors.lightGreen.shade400,
        int() => Colors.redAccent,
      };
}
