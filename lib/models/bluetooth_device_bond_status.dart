//

enum BluetoothDeviceBondStatus {
  notBond,
  bonding,
  bonded,
  unknown;

  factory BluetoothDeviceBondStatus.fromString(String value) => switch (value) {
        'Not Bonded' => BluetoothDeviceBondStatus.notBond,
        'Bonding' => BluetoothDeviceBondStatus.bonding,
        'Bonded' => BluetoothDeviceBondStatus.bonded,
        String() => BluetoothDeviceBondStatus.unknown,
      };
}
