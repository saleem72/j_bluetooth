// import 'package:flutter_test/flutter_test.dart';
// import 'package:j_bluetooth/j_bluetooth.dart';
// import 'package:j_bluetooth/j_bluetooth_platform_interface.dart';
// import 'package:j_bluetooth/j_bluetooth_method_channel.dart';
// import 'package:plugin_platform_interface/plugin_platform_interface.dart';

// class MockJBluetoothPlatform
//     with MockPlatformInterfaceMixin
//     implements JBluetoothPlatform {

//   @override
//   Future<String?> getPlatformVersion() => Future.value('42');
// }

// void main() {
//   final JBluetoothPlatform initialPlatform = JBluetoothPlatform.instance;

//   test('$MethodChannelJBluetooth is the default instance', () {
//     expect(initialPlatform, isInstanceOf<MethodChannelJBluetooth>());
//   });

//   test('getPlatformVersion', () async {
//     JBluetooth jBluetoothPlugin = JBluetooth();
//     MockJBluetoothPlatform fakePlatform = MockJBluetoothPlatform();
//     JBluetoothPlatform.instance = fakePlatform;

//     expect(await jBluetoothPlugin.getPlatformVersion(), '42');
//   });
// }
