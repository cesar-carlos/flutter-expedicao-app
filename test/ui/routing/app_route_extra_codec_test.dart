import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:data7_expedicao/core/routing/route_extra.dart';
import 'package:data7_expedicao/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/routing/app_route_extra_codec.dart';

class _PickingViewModel extends Mock implements CardPickingViewModel {}

void main() {
  const codec = AppRouteExtraCodec();
  final user = UserSystemModel.fromJson({
    'CodUsuario': 1,
    'NomeUsuario': 'Administrador',
    'Ativo': 'S',
    'CodEmpresa': 1,
    'CodSetorEstoque': 2,
  });
  final cart = ExpeditionCartRouteInternshipConsultationModel.fromJson({
    'CodEmpresa': 1,
    'CodCarrinhoPercurso': 289597,
    'Item': '00003',
    'CodPercursoEstagio': 3,
    'Origem': 'SE',
    'CodOrigem': 290901,
    'Situacao': 'SEPARANDO',
    'CarrinhoAgrupador': 'N',
    'CodCarrinho': 5,
    'NomeCarrinho': 'CARRINHO 5',
    'CodigoBarrasCarrinho': '00001520240603',
    'Ativo': 'S',
    'CodUsuarioInicio': 1,
    'NomeUsuarioInicio': 'Administrador',
    'DataInicio': '2026-11-13',
    'HoraInicio': '14:18:26',
    'CodSetorEstoque': 2,
  });

  test('should preserve picking models after a JSON round trip', () {
    final encoded = jsonEncode(codec.encode({'cart': cart, 'userModel': user}));
    final restored = codec.decode(jsonDecode(encoded)) as Map<String, Object?>;
    expect((restored['cart'] as ExpeditionCartRouteInternshipConsultationModel).toJson(), cart.toJson());
    expect((restored['userModel'] as UserSystemModel).toMap(), user.toMap());
  });

  test('should preserve nested primitives without confusing maps with type tags', () {
    final extra = {
      'type': 'user',
      'data': ['cart', null, true, 4.5],
      'nested': {'a': 1},
    };
    expect(codec.decode(jsonDecode(jsonEncode(codec.encode(extra)))), extra);
  });

  test('should report an expired session when restoring a live view model', () {
    final encoded = jsonEncode(codec.encode({'cart': cart, 'viewModel': _PickingViewModel()}));
    expect(codec.decode(jsonDecode(encoded)), isA<RouteExtraFailure>());
  });

  test('should reject unsupported extras instead of discarding them', () {
    expect(() => codec.encode({'unsupported': Object()}), throwsUnsupportedError);
    expect(() => codec.encode({1: 'invalid key'}), throwsFormatException);
    expect(codec.decode(['unknown', {}]), isA<RouteExtraFailure>());
  });

  test('should report malformed restored model data instead of using default identifiers', () {
    expect(codec.decode(['user', <String, Object?>{}]), isA<RouteExtraFailure>());
    expect(
      codec.decode([
        'cart',
        {...cart.toJson(), 'DataInicio': 'invalid'},
      ]),
      isA<RouteExtraFailure>(),
    );
    expect(
      codec.decode([
        'cart',
        {...cart.toJson(), 'CodCarrinho': null},
      ]),
      isA<RouteExtraFailure>(),
    );
  });

  testWidgets('should report navigation to Android with user cart and live view model extras', (tester) async {
    final calls = <MethodCall>[];
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.navigation, (call) async {
      calls.add(call);
      return null;
    });
    addTearDown(() => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(SystemChannels.navigation, null));
    final viewModel = _PickingViewModel();
    Object? receivedPicking;
    Object? receivedProducts;
    final router = GoRouter(
      extraCodec: codec,
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('Início')),
        ),
        GoRoute(
          path: '/picking',
          builder: (_, state) {
            receivedPicking = state.extra;
            return const Scaffold(body: Text('Picking'));
          },
        ),
        GoRoute(
          path: '/products',
          builder: (_, state) {
            receivedProducts = state.extra;
            return const Scaffold(body: Text('Produtos'));
          },
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    router.push<void>('/picking', extra: {'cart': cart, 'userModel': user});
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect((receivedPicking as Map)['userModel'], same(user));
    router.push<void>('/products', extra: {'cart': cart, 'viewModel': viewModel});
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect((receivedProducts as Map)['viewModel'], same(viewModel));
    expect(calls.where((call) => call.method == 'routeInformationUpdated'), isNotEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    router.dispose();
  });
}
