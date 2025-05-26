//

import 'package:flutter/material.dart';

enum BluetoothDeviceMajorType {
  computer,
  phone,
  lAN,
  audio,
  peripheral,
  imaging,
  wearable,
  toy,
  health,
  unCategorized;

  String get caption {
    switch (this) {
      case computer:
        return "Computer";
      case phone:
        return "Phone";
      case lAN:
        return "LAN/Network Access Point";
      case audio:
        return "Audio/Video";
      case peripheral:
        return "Peripheral";
      case imaging:
        return "Imaging";
      case wearable:
        return "Wearable";
      case toy:
        return "Toy";
      case health:
        return "Health";
      case unCategorized:
        return "UnCategorized";
    }
  }

  Color get color {
    switch (this) {
      case BluetoothDeviceMajorType.computer:
        return Color(0xFFFFC300);
      case BluetoothDeviceMajorType.phone:
        return Color(0xFF2196F3);
      // case BluetoothDeviceTypeNew.lAN:
      //   return Colors.white;
      case BluetoothDeviceMajorType.audio:
        return Color(0xFF3BFF49);
      // case BluetoothDeviceTypeNew.peripheral:
      //   return Colors.white;
      case BluetoothDeviceMajorType.imaging:
        return Color(0xFF6E1BFF);
      // case BluetoothDeviceTypeNew.wearable:
      //   return Colors.white;
      // case BluetoothDeviceTypeNew.toy:
      //   return Colors.white;
      // case BluetoothDeviceTypeNew.health:
      //   return Colors.white;
      // case BluetoothDeviceTypeNew.unCategorized:
      //   return Colors.white;
      default:
        return Color(0xFFD8DC2F);
    }
  }

  IconData get icon {
    switch (this) {
      case BluetoothDeviceMajorType.computer:
        return Icons.computer;
      case BluetoothDeviceMajorType.phone:
        return Icons.smartphone;
      case BluetoothDeviceMajorType.lAN:
        return Icons.lan;
      case BluetoothDeviceMajorType.audio:
        return Icons.headphones;
      case BluetoothDeviceMajorType.peripheral:
        return Icons.mouse;
      case BluetoothDeviceMajorType.imaging:
        return Icons.print;
      case BluetoothDeviceMajorType.wearable:
        return Icons.watch;
      case BluetoothDeviceMajorType.toy:
        return Icons.toys;
      case BluetoothDeviceMajorType.health:
        return Icons.monitor_heart;
      case BluetoothDeviceMajorType.unCategorized:
        return Icons.devices;
    }
  }

  factory BluetoothDeviceMajorType.fromDeviceClass(int deviceClass) {
    switch (deviceClass) {
      case 0x0100:
        return BluetoothDeviceMajorType.computer;
      case 0x0200:
        return BluetoothDeviceMajorType.phone;
      case 0x0300:
        return BluetoothDeviceMajorType.lAN;
      case 0x0400:
        return BluetoothDeviceMajorType.audio;
      case 0x0500:
        return BluetoothDeviceMajorType.peripheral;
      case 0x0600:
        return BluetoothDeviceMajorType.imaging;
      case 0x0700:
        return BluetoothDeviceMajorType.wearable;
      case 0x0800:
        return BluetoothDeviceMajorType.toy;
      case 0x0900:
        return BluetoothDeviceMajorType.health;
      default:
        return BluetoothDeviceMajorType.unCategorized;
    }
  }
}
