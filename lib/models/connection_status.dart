// ignore_for_file: public_member_api_docs, sort_constructors_first
//

class ConnectionStatus {
  final bool serverStatus;
  final bool connectionStatus;

  ConnectionStatus({
    required this.serverStatus,
    required this.connectionStatus,
  });

  factory ConnectionStatus.fromMap(Map map) {
    return ConnectionStatus(
      serverStatus: map["serverStatus"] is bool ? map["serverStatus"] : false,
      connectionStatus:
          map["connectionStatus"] is bool ? map["connectionStatus"] : false,
    );
  }

  factory ConnectionStatus.empty() => ConnectionStatus(
        serverStatus: false,
        connectionStatus: false,
      );
}
