import 'package:data7_expedicao/domain/models/event_model/event_listener_model.dart';

class BasicEventModel {
  final String? session;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final Event eventType;

  const BasicEventModel({this.session, this.data, required this.timestamp, required this.eventType});

  factory BasicEventModel.fromJson(Map<String, dynamic> json) {
    // Bug latente anterior: `data: json['data'] ?? json['Data']` fazia
    // cast implicito Object? -> Map<String, dynamic>?. Se viesse
    // List ou String, crashava com TypeError no acesso. Agora valida
    // explicitamente o tipo.
    // Bug similar: `session` aceitava qualquer tipo (int, etc).
    // Bug timestamp: `DateTime.tryParse(json['timestamp'])` exigia
    // String — se viesse int (epoch) ou null direto crashava no cast.
    final sessionRaw = json['session'] ?? json['Session'];
    final dataRaw = json['data'] ?? json['Data'];
    final tsRaw = json['timestamp'];
    return BasicEventModel(
      session: sessionRaw?.toString(),
      data: dataRaw is Map ? Map<String, dynamic>.from(dataRaw) : null,
      timestamp: tsRaw is String ? (DateTime.tryParse(tsRaw) ?? DateTime.now()) : DateTime.now(),
      eventType: _parseEventType(json['eventType'] ?? json['EventType']),
    );
  }

  factory BasicEventModel.empty({Event eventType = Event.insert}) {
    return BasicEventModel(session: null, data: null, timestamp: DateTime.now(), eventType: eventType);
  }

  factory BasicEventModel.create({String? session, Map<String, dynamic>? data, Event eventType = Event.insert}) {
    return BasicEventModel(session: session, data: data, timestamp: DateTime.now(), eventType: eventType);
  }

  static Event _parseEventType(dynamic eventType) {
    if (eventType == null) return Event.insert;

    final String typeStr = eventType.toString().toLowerCase();
    switch (typeStr) {
      case 'insert':
      case 'created':
      case 'add':
        return Event.insert;
      case 'update':
      case 'modified':
      case 'changed':
        return Event.update;
      case 'delete':
      case 'removed':
      case 'deleted':
        return Event.delete;
      default:
        return Event.insert;
    }
  }

  Map<String, dynamic> toJson() {
    return {'session': session, 'data': data, 'timestamp': timestamp.toIso8601String(), 'eventType': eventType.name};
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
    return 'BasicEventModel(session: $session, eventType: ${eventType.name}, timestamp: $timestamp)';
  }
}
