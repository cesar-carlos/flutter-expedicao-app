/// Modelo básico para eventos de repositório
class BasicEventModel {
  final String? session;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final String? eventType;

  const BasicEventModel({
    this.session,
    this.data,
    required this.timestamp,
    this.eventType,
  });

  factory BasicEventModel.fromJson(Map<String, dynamic> json) {
    return BasicEventModel(
      session: json['session'] ?? json['Session'],
      data: json['data'] ?? json['Data'],
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp']) ?? DateTime.now()
          : DateTime.now(),
      eventType: json['eventType'] ?? json['EventType'],
    );
  }

  /// Cria um evento vazio
  factory BasicEventModel.empty() {
    return BasicEventModel(
      session: null,
      data: null,
      timestamp: DateTime.now(),
      eventType: null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'session': session,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'eventType': eventType,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BasicEventModel &&
        other.session == session &&
        other.eventType == eventType &&
        other.timestamp == timestamp;
  }

  @override
  int get hashCode {
    return session.hashCode ^ eventType.hashCode ^ timestamp.hashCode;
  }

  @override
  String toString() {
    return 'BasicEventModel(session: $session, eventType: $eventType, timestamp: $timestamp)';
  }
}
