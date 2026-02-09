import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/domain/models/expedition_item_print_consultation_model.dart';
import 'package:data7_expedicao/domain/models/pagination/query_builder.dart';
import 'package:data7_expedicao/data/repositories/expedition_item_print_consultation_repository_impl.dart';

import '../../core/socket_integration_test_base.dart';

void main() {
  group('ExpeditionItemPrintConsultationRepositoryImpl', () {
    late ExpeditionItemPrintConsultationRepositoryImpl repository;

    setUpAll(() async {
      await SocketIntegrationTestBase.setupSocket();
    });

    setUp(() {
      repository = ExpeditionItemPrintConsultationRepositoryImpl();
    });

    tearDownAll(() async {
      await SocketIntegrationTestBase.tearDownSocket();
    });

    test(
      'selectConsultation com top 100 retorna lista e no máximo 100 registros',
      skip: true,
      timeout: const Timeout(Duration(seconds: 20)),
      () async {
        final queryBuilder = QueryBuilder().paginate(limit: 100, offset: 0, page: 1);

        final result = await repository.selectConsultation(queryBuilder);

        expect(result, isA<List<ExpeditionItemPrintConsultationModel>>());
        expect(result.length, lessThanOrEqualTo(100), reason: 'Deve retornar no máximo 100 registros');

        if (result.isNotEmpty) {
          expect(result.first, isA<ExpeditionItemPrintConsultationModel>());
          expect(result.first.codEmpresa, greaterThan(0));
          expect(result.first.item, isNotEmpty);
        }

        await SocketIntegrationTestBase.waitForOperation();
      },
    );
  });
}
