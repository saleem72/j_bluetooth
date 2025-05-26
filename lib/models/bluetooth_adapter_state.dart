//

enum BluetoothAdapterState {
  off,
  turningOn,
  on,
  turningOff,
  unknown;

  factory BluetoothAdapterState.fromCode(int? code) => switch (code) {
        10 => BluetoothAdapterState.off,
        11 => BluetoothAdapterState.turningOn,
        12 => BluetoothAdapterState.on,
        13 => BluetoothAdapterState.turningOff,
        int() => BluetoothAdapterState.unknown,
        null => BluetoothAdapterState.unknown
      };

  factory BluetoothAdapterState.fromString(String value) => switch (value) {
        'off' => BluetoothAdapterState.off,
        'turning_on' => BluetoothAdapterState.turningOn,
        'on' => BluetoothAdapterState.on,
        'turning_off' => BluetoothAdapterState.turningOff,
        String() => BluetoothAdapterState.unknown,
      };
}
