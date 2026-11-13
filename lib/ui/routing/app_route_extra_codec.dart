import 'dart:convert';

import 'package:data7_expedicao/core/routing/route_extra.dart';
import 'package:data7_expedicao/core/utils/app_logger.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';

final class AppRouteExtraCodec extends Codec<Object?, Object?> {
  const AppRouteExtraCodec();

  @override
  Converter<Object?, Object?> get encoder => const _RouteExtraEncoder();

  @override
  Converter<Object?, Object?> get decoder => const _RouteExtraDecoder();
}

final class _RouteExtraEncoder extends Converter<Object?, Object?> {
  const _RouteExtraEncoder();

  @override
  Object? convert(Object? input) {
    return switch (input) {
      null || bool() || String() || int() => input,
      double value when value.isFinite => value,
      UserSystemModel user => ['user', user.toMap()],
      ExpeditionCartRouteInternshipConsultationModel cart => ['cart', cart.toJson()],
      // O extra original permanece em memoria. Um ViewModel nao pode ser
      // recriado a partir do historico apos o encerramento desse fluxo.
      CardPickingViewModel() => ['picking-session'],
      RouteExtraFailure(:final message) => ['failure', message],
      List values => ['list', values.map(convert).toList()],
      Map values => ['map', _encodeMap(values)],
      _ => throw UnsupportedError('Tipo de argumento de navegacao nao suportado: ${input.runtimeType}'),
    };
  }

  Map<String, Object?> _encodeMap(Map values) {
    final result = <String, Object?>{};
    for (final entry in values.entries) {
      final key = entry.key;
      if (key is! String) {
        throw const FormatException('Argumentos de navegacao devem ter chaves de texto.');
      }
      result[key] = convert(entry.value);
    }
    return result;
  }
}

final class _RouteExtraDecoder extends Converter<Object?, Object?> {
  const _RouteExtraDecoder();

  @override
  Object? convert(Object? input) {
    try {
      return _decode(input);
    } catch (error, stackTrace) {
      AppLogger.error(
        'Falha ao restaurar argumentos da navegacao',
        tag: 'AppRouteExtraCodec',
        error: error,
        stackTrace: stackTrace,
      );
      return const RouteExtraFailure(
        'Não foi possível restaurar esta tela. Volte ao início e abra a separação novamente.',
      );
    }
  }

  Object? _decode(Object? input) {
    return switch (input) {
      null || bool() || String() || int() => input,
      double value when value.isFinite => value,
      ['user', Map data] => _decodeUser(data),
      ['cart', Map data] => _decodeCart(data),
      ['list', List values] => _decodeList(values),
      ['map', Map values] => _decodeMap(values),
      ['failure', String message] => RouteExtraFailure(message),
      ['picking-session'] => const RouteExtraFailure(
        'Esta tela depende de uma sessão de picking encerrada. Volte ao início e reabra a separação.',
      ),
      _ => throw const FormatException('Formato de argumentos de navegacao invalido.'),
    };
  }

  Object _decodeList(List values) {
    final result = <Object?>[];
    for (final value in values) {
      final decoded = _decode(value);
      if (decoded is RouteExtraFailure) return decoded;
      result.add(decoded);
    }
    return result;
  }

  Object _decodeMap(Map values) {
    final result = <String, Object?>{};
    for (final entry in values.entries) {
      final decoded = _decode(entry.value);
      if (decoded is RouteExtraFailure) return decoded;
      result[_decodeKey(entry.key)] = decoded;
    }
    return result;
  }

  UserSystemModel _decodeUser(Map data) {
    if (data case {'CodUsuario': int(), 'NomeUsuario': String(), 'Ativo': 'S' || 'N'}) {
      return UserSystemModel.fromJson(Map<String, dynamic>.from(data));
    }
    throw const FormatException('Identificacao do usuario ausente ou invalida no historico de navegacao.');
  }

  ExpeditionCartRouteInternshipConsultationModel _decodeCart(Map data) {
    if (data case {
      'CodEmpresa': int(),
      'CodCarrinhoPercurso': int(),
      'Item': String(),
      'CodCarrinho': int(),
      'CodOrigem': int(),
      'Situacao': String(),
      'DataInicio': String date,
    }) {
      if (DateTime.tryParse(date) != null) {
        return ExpeditionCartRouteInternshipConsultationModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw const FormatException('Identificacao do carrinho ausente ou invalida no historico de navegacao.');
  }

  String _decodeKey(Object? key) {
    if (key is String) return key;
    throw const FormatException('Chave de argumento de navegacao invalida.');
  }
}
