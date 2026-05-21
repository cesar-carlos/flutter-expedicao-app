import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/presentation/viewmodels/picking_scan_result.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/scan_ui_controller.dart';

class _SilentAudioService extends Fake implements AudioService {}

void main() {
  testWidgets('restaura a quantidade original quando a adicao falha apos conversao', (tester) async {
    late BuildContext capturedContext;
    final scanFocusNode = FocusNode();
    final quantityController = TextEditingController(text: '2');

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return Focus(focusNode: scanFocusNode, child: const SizedBox.shrink());
            },
          ),
        ),
      ),
    );

    final controller = ScanUiController(
      dialogManager: PickingDialogManager(context: capturedContext, scanFocusNode: scanFocusNode),
      audioService: _SilentAudioService(),
      keyboardController: KeyboardToggleController(scanFocusNode: scanFocusNode, context: capturedContext),
      quantityController: quantityController,
      onFinishPicking: () async {},
      onAddItem: (item, barcode, quantity, originalQuantity) async => false,
      context: capturedContext,
    );

    await controller.handleScanResult('CX12', ScanProcessResult.success(_buildItem(), 24), 2);

    expect(quantityController.text, equals('2'));
  });
}

SeparateItemConsultationModel _buildItem() {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 123,
    item: '00001',
    origem: ExpeditionOrigem.separacaoEstoque,
    codOrigem: 123,
    codProduto: 1,
    nomeProduto: 'Produto 1',
    ativo: Situation.ativo,
    codTipoProduto: 'P',
    codUnidadeMedida: 'UN',
    nomeUnidadeMedida: 'Unidade',
    codGrupoProduto: 1,
    nomeGrupoProduto: 'Grupo',
    codSetorEstoque: 1,
    nomeSetorEstoque: 'Setor 1',
    endereco: 'A1',
    enderecoDescricao: 'A1',
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Endereco',
    quantidade: 100,
    quantidadeInterna: 100,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: const [],
  );
}
