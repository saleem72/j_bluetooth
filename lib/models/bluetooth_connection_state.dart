//

enum BluetoothConnectionState {
  connected,
  disconnected;

  factory BluetoothConnectionState.fromString(String value) => switch (value) {
        'connected' => BluetoothConnectionState.connected,
        String() => BluetoothConnectionState.disconnected,
      };
}
