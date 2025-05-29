//

class PluginError {
  final String code;
  final String message;

  PluginError({
    required this.code,
    required this.message,
  });

  factory PluginError.fromMap(Map<String, dynamic> map) {
    return PluginError(
      code: map['code'] ?? 'UNKNOWN',
      message: map['message'] ?? 'An unknown error occurred.',
    );
  }

  @override
  String toString() => '[$code] $message';
}
