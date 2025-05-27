// ignore_for_file: public_member_api_docs, sort_constructors_first
//

import 'package:equatable/equatable.dart';

class ConnectedDevice extends Equatable {
  final String address;
  final String name;
  final bool isConnected;

  const ConnectedDevice({
    required this.address,
    required this.name,
    required this.isConnected,
  });

  factory ConnectedDevice.fromMap(dynamic map) => ConnectedDevice(
        address: map["address"],
        name: map["name"],
        isConnected: map["isConnected"],
      );

  @override
  List<Object?> get props => [address];
}
