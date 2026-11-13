import 'dart:convert';

/// Aviso do canal `servidor.emergencia.listen`. Familia `{ Data }`, sem
/// `Session` — nao filtrar por sessao.
final class ServidorEmergenciaAvisoModel {
  static const String channelName = 'servidor.emergencia.listen';
  static const String listenerId = 'servidor-emergencia-global';

  final String nivel;
  final String codigo;
  final String mensagem;
  final String acao;
  final int prazoMs;
  final String? emitidoEm;

  const ServidorEmergenciaAvisoModel({
    required this.nivel,
    required this.codigo,
    required this.mensagem,
    required this.acao,
    required this.prazoMs,
    this.emitidoEm,
  });

  bool get vaiDesconectar => acao == 'desconectar';

  String get titulo {
    if (vaiDesconectar || nivel == 'desconectar') {
      return 'Sessão será encerrada';
    }
    if (nivel == 'urgente') {
      return 'Aviso urgente';
    }
    return 'Aviso do servidor';
  }

  String get detalhe {
    if (!vaiDesconectar || prazoMs <= 0) {
      return mensagem;
    }
    final seconds = (prazoMs / 1000).ceil();
    final unidade = seconds == 1 ? 'segundo' : 'segundos';
    return '$mensagem\n\nA conexão será encerrada em $seconds $unidade.';
  }

  factory ServidorEmergenciaAvisoModel.fromJson(Map<String, dynamic> json) {
    return ServidorEmergenciaAvisoModel(
      nivel: json['Nivel']?.toString() ?? 'aviso',
      codigo: json['Codigo']?.toString() ?? '',
      mensagem: json['Mensagem']?.toString() ?? '',
      acao: json['Acao']?.toString() ?? 'nenhuma',
      prazoMs: _prazoOf(json['PrazoMs']),
      emitidoEm: json['EmitidoEm']?.toString(),
    );
  }

  static ServidorEmergenciaAvisoModel? fromPayload(Object? payload) {
    final decoded = _asMap(payload);
    if (decoded == null) {
      return null;
    }

    final data = decoded['Data'] ?? decoded['data'];
    if (data is List) {
      if (data.isEmpty) {
        return null;
      }
      final first = data.first;
      if (first is! Map) {
        return null;
      }
      return ServidorEmergenciaAvisoModel.fromJson(Map<String, dynamic>.from(first));
    }

    if (decoded.containsKey('Nivel') || decoded.containsKey('Mensagem') || decoded.containsKey('Acao')) {
      return ServidorEmergenciaAvisoModel.fromJson(decoded);
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(Object? payload) {
    return switch (payload) {
      String text => _decodeMap(text),
      Map map => Map<String, dynamic>.from(map),
      List list when list.isNotEmpty && list.first is Map => Map<String, dynamic>.from(list.first as Map),
      _ => null,
    };
  }

  static Map<String, dynamic>? _decodeMap(String text) {
    try {
      final decoded = jsonDecode(text);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } on FormatException {
      return null;
    }
  }

  static int _prazoOf(Object? value) {
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
