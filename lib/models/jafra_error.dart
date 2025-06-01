//

class JafraError {
  final String code;
  final String message;

  JafraError({
    required this.code,
    required this.message,
  });

  factory JafraError.fromMap(Map<String, dynamic> map) {
    return JafraError(
      code: map['code'] ?? 'UNKNOWN',
      message: map['message'] ?? 'An unknown error occurred.',
    );
  }

  @override
  String toString() => '[$code] $message';
}
