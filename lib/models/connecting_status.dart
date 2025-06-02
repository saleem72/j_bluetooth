// ignore_for_file: public_member_api_docs, sort_constructors_first
//

class ConnectingStatus {
  final bool serverStatus;
  final bool connectionStatus;

  ConnectingStatus({
    required this.serverStatus,
    required this.connectionStatus,
  });

  factory ConnectingStatus.fromMap(Map map) {
    return ConnectingStatus(
      serverStatus: map["serverStatus"] is bool ? map["serverStatus"] : false,
      connectionStatus:
          map["connectionStatus"] is bool ? map["connectionStatus"] : false,
    );
  }

  factory ConnectingStatus.empty() => ConnectingStatus(
        serverStatus: false,
        connectionStatus: false,
      );

  @override
  String toString() =>
      'ConnectingStatus(serverStatus: $serverStatus, connectionStatus: $connectionStatus)';
}
