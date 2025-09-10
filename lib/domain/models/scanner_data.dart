/// Modelo de dados para informações do scanner
class ScannerData {
  final String code;

  final DateTime timestamp;

  bool get isValid => code.isNotEmpty;

  ScannerData({required this.code, DateTime? timestamp})
    : timestamp = timestamp ?? DateTime.now();

  ScannerData copyWith({String? code, DateTime? timestamp}) {
    return ScannerData(
      code: code ?? this.code,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}
