//

import 'dart:developer';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:j_bluetooth/j_bluetooth.dart';
import 'package:j_bluetooth_example/chat_screen.dart';

void main() {
  runApp(const MyAPp());
}

class MyAPp extends StatelessWidget {
  const MyAPp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _jafraBluetoothPlugin = JBluetooth();
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _isDiscoveringSubscription;
  StreamSubscription<ConnectedDevice>? _connectedDeviceSubscription;
  StreamSubscription<JafraBluetoothDevice>? _devicesSubscription;
  String adapterName = 'Unknown';
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  List<JafraBluetoothDevice> devices = [];
  List<JafraBluetoothDevice> pairedDevices = [];
  bool isDiscovering = false;
  ConnectedDevice? connectedDevice;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    _isDiscoveringSubscription?.cancel();
    _devicesSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _jafraBluetoothPlugin.dispose();
    _connectedDeviceSubscription?.cancel();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _jafraBluetoothPlugin.adapterName ?? 'Unknown platform version';
      adapterState = await _jafraBluetoothPlugin.state;

      pairedDevices = await _jafraBluetoothPlugin.pairedDevices();

      _adapterStateSubscription =
          _jafraBluetoothPlugin.discoveredDevices().listen((r) {
        setState(() {
          adapterState = r;
        });
      });

      _isDiscoveringSubscription =
          _jafraBluetoothPlugin.isDiscovering().listen((event) {
        setState(() {
          isDiscovering = event;
        });
      });

      _connectedDeviceSubscription =
          _jafraBluetoothPlugin.connectedDevice().listen((device) {
        log(device.address);
        connectedDevice = device;
        setState(() {});
        _push(device);
      });

      _devicesSubscription = _jafraBluetoothPlugin.onDevice().listen((event) {
        if (devices.contains(event)) {
          return;
        }

        if (event.name == null) {
          return;
        }

        if (event.name!.isEmpty) {
          return;
        }
        devices.add(event);
        setState(() {});
      });
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      adapterName = platformVersion;
    });
  }

  _push(ConnectedDevice device) {
    if (device.isConnected) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => ChatScreen(
                  device: device,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
        actions: [
          IconButton(
            onPressed: () {
              // {address: 90:CB:A3:7E:FA:D8, name: TECNO SPARK Go 2024, isConnected: true}
              const device = ConnectedDevice(
                address: "90:CB:A3:7E:FA:D8",
                name: "TECNO SPARK Go 2024",
                isConnected: true,
              );
              _push(device);
            },
            icon: const Icon(Icons.chat),
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildContent(context),
          isDiscovering
              ? Container(
                  color: Colors.black38,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                onPressed: () {
                  devices.clear();
                  setState(() {});
                  _jafraBluetoothPlugin.startDiscover();
                },
                child: const Text('Start discover'),
              ),
              FilledButton(
                onPressed: () => _jafraBluetoothPlugin.stopDiscover(),
                child: const Text('Stop discover'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              FilledButton(
                onPressed: () => _jafraBluetoothPlugin.startServer(),
                child: const Text('Start server'),
              ),
              FilledButton(
                onPressed: () => _jafraBluetoothPlugin
                    .sendMessage('hello from $adapterName'),
                child: const Text('Send message'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            children: [
              ...pairedDevices.map((e) => DeviceTile(
                    device: e,
                  ))
            ],
          ),
          const SizedBox(height: 16),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KeyValueWidget(
                label: 'Adapter name',
                value: adapterName,
              ),
              const SizedBox(height: 8),
              KeyValueWidget(
                label: 'Adapter state',
                value: adapterState.toString(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Devices',
            style: context.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: devices.length,
              separatorBuilder: (BuildContext context, int index) {
                return const SizedBox(height: 16);
              },
              itemBuilder: (BuildContext context, int index) {
                final device = devices[index];
                return DeviceTile(
                    onTap: () => _jafraBluetoothPlugin.connectToServer(device),
                    device: device);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class KeyValueWidget extends StatelessWidget {
  const KeyValueWidget({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$label: ',
          style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}

extension ContextDetails on BuildContext {
  TextTheme get textTheme => Theme.of(this).textTheme;
}
