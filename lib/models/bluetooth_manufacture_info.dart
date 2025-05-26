//

import 'BluetoothDeviceMajorType.dart';
import 'BluetoothDeviceMinorType.dart';

class BluetoothManufactureInfo {
  final int? deviceClass;
  final int? majorDeviceClass;
  final int? minorDeviceClass;
  final BluetoothDeviceMajorType deviceCategory;
  final BluetoothDeviceMinorType? fullClassCategory;

  String get category => fullClassCategory?.caption ?? deviceCategory.caption;

  BluetoothManufactureInfo({
    this.majorDeviceClass,
    required this.deviceCategory,
    this.minorDeviceClass,
    this.deviceClass,
    this.fullClassCategory,
  });

  factory BluetoothManufactureInfo.fromMap(Map map) {
    return BluetoothManufactureInfo(
      majorDeviceClass: map['majorDeviceClass'],
      minorDeviceClass: map['minorDeviceClass'],
      deviceCategory: map['majorDeviceClass'] is int
          ? BluetoothDeviceMajorType.fromDeviceClass(map['majorDeviceClass'])
          : BluetoothDeviceMajorType.unCategorized,
      deviceClass: map['deviceClass'],
      fullClassCategory: map['deviceClass'] is int
          ? BluetoothDeviceMinorType.fromFullClass(map['deviceClass'])
          : BluetoothDeviceMinorType.unknownDevice,
    );
  }
}
