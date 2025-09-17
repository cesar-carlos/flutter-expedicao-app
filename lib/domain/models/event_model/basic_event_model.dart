import 'package:exp/domain/models/event_model/event_listener_model.dart';

/// Modelo básico para eventos de repositório
class BasicEventModel {
  final String? session;
  final Map<String, dynamic>? data;
  final DateTime timestamp;
  final Event eventType;

  const BasicEventModel({this.session, this.data, required this.timestamp, required this.eventType});

  factory BasicEventModel.fromJson(Map<String, dynamic> json) {
    return BasicEventModel(
      session: json['session'] ?? json['Session'],
      data: json['data'] ?? json['Data'],
      timestamp: json['timestamp'] != null ? DateTime.tryParse(json['timestamp']) ?? DateTime.now() : DateTime.now(),
      eventType: _parseEventType(json['eventType'] ?? json['EventType']),
    );
  }

  /// Cria um evento vazio com tipo padrão
  factory BasicEventModel.empty({Event eventType = Event.insert}) {
    return BasicEventModel(session: null, data: null, timestamp: DateTime.now(), eventType: eventType);
  }

  /// Cria um evento específico
  factory BasicEventModel.create({String? session, Map<String, dynamic>? data, Event eventType = Event.insert}) {
    return BasicEventModel(session: session, data: data, timestamp: DateTime.now(), eventType: eventType);
  }

  /// Converte o tipo de evento de string para enum
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
        return Event.insert; // Fallback
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
