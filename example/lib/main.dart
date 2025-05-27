//

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:j_bluetooth/j_bluetooth.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _jafraBluetoothPlugin = JBluetooth();
  StreamSubscription<BluetoothAdapterState>? _adapterStateSubscription;
  StreamSubscription<bool>? _isDiscoveringSubscription;
  StreamSubscription<JafraBluetoothDevice>? _devicesSubscription;
  String adapterName = 'Unknown';
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  List<JafraBluetoothDevice> devices = [];
  bool isDiscovering = false;

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
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
                onPressed: () => _jafraBluetoothPlugin.connectToServer(),
                child: const Text('Start server'),
              ),
              FilledButton(
                onPressed: () {},
                child: const Text('Stop server'),
              ),
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
                return DeviceTile(result: device);
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
