import 'package:flutter_test/flutter_test.dart';

import 'package:data7_expedicao/core/services/audio_service.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/presentation/viewmodels/card_picking_viewmodel.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/keyboard_toggle_controller.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_dialog_manager.dart';
import 'package:data7_expedicao/ui/widgets/card_picking/components/picking_flow_controller.dart';

class _RecordingAudioService extends Fake implements AudioService {
  int alertCompleteCount = 0;

  @override
  Future<void> playAlertComplete() async {
    alertCompleteCount += 1;
  }
}

class _RecordingDialogManager extends Fake implements PickingDialogManager {
  int saveCartDialogCount = 0;

  @override
  void showSaveCartAfterSectorCompletedDialog(
    int userSectorCode,
    void Function() onSaveCart,
    void Function() onContinue,
  ) {
    saveCartDialogCount += 1;
  }
}

class _NoOpKeyboardToggleController extends Fake implements KeyboardToggleController {
  @override
  void forceFocusAndCloseKeyboard() {}
}

class _FakeCardPickingViewModel extends Fake implements CardPickingViewModel {
  _FakeCardPickingViewModel({required this.user, required this.currentItems, required this.completedItemIds});

  final UserSystemModel user;
  final List<SeparateItemConsultationModel> currentItems;
  final Set<String> completedItemIds;

  @override
  UserSystemModel? get userModel => user;

  @override
  List<SeparateItemConsultationModel> get items => currentItems;

  @override
  bool isItemCompleted(String itemId) => completedItemIds.contains(itemId);
}

void main() {
  group('PickingFlowController.checkAndShowSaveCartModal', () {
    test('mostra o modal apenas uma vez enquanto o setor permanece completo', () async {
      final dialogManager = _RecordingDialogManager();
      final audioService = _RecordingAudioService();
      final completedItems = <String>{'1'};
      final controller = PickingFlowController(
        viewModel: _FakeCardPickingViewModel(
          user: _buildUserModel(),
          currentItems: [_buildItem(item: '1', codSetorEstoque: 1)],
          completedItemIds: completedItems,
        ),
        dialogManager: dialogManager,
        audioService: audioService,
        keyboardController: _NoOpKeyboardToggleController(),
      );

      await controller.checkAndShowSaveCartModal();
      await controller.checkAndShowSaveCartModal();

      expect(audioService.alertCompleteCount, equals(1));
      expect(dialogManager.saveCartDialogCount, equals(1));
    });

    test('permite exibir novamente se o setor voltar a ficar incompleto e completar de novo', () async {
      final dialogManager = _RecordingDialogManager();
      final audioService = _RecordingAudioService();
      final completedItems = <String>{'1'};
      final viewModel = _FakeCardPickingViewModel(
        user: _buildUserModel(),
        currentItems: [_buildItem(item: '1', codSetorEstoque: 1)],
        completedItemIds: completedItems,
      );
      final controller = PickingFlowController(
        viewModel: viewModel,
        dialogManager: dialogManager,
        audioService: audioService,
        keyboardController: _NoOpKeyboardToggleController(),
      );

      await controller.checkAndShowSaveCartModal();
      completedItems.clear();
      await controller.checkAndShowSaveCartModal();
      completedItems.add('1');
      await controller.checkAndShowSaveCartModal();

      expect(audioService.alertCompleteCount, equals(2));
      expect(dialogManager.saveCartDialogCount, equals(2));
    });
  });
}

SeparateItemConsultationModel _buildItem({required String item, required int? codSetorEstoque}) {
  return SeparateItemConsultationModel(
    codEmpresa: 1,
    codSepararEstoque: 123,
    item: item,
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
    codSetorEstoque: codSetorEstoque,
    nomeSetorEstoque: codSetorEstoque == null ? null : 'Setor $codSetorEstoque',
    endereco: 'A1',
    enderecoDescricao: 'A1',
    codLocalArmazenagem: 1,
    nomeLocaArmazenagem: 'Endereco',
    quantidade: 1,
    quantidadeInterna: 1,
    quantidadeExterna: 0,
    quantidadeSeparacao: 0,
    unidadeMedidas: const [],
  );
}

UserSystemModel _buildUserModel() {
  return UserSystemModel(
    codUsuario: 10,
    nomeUsuario: 'Usuario',
    ativo: Situation.ativo,
    codEmpresa: 1,
    codSetorEstoque: 1,
    nomeSetorEstoque: 'Setor 1',
    permiteSepararForaSequencia: Situation.ativo,
    visualizaTodasSeparacoes: Situation.ativo,
    expedicaoObrigaEscanearPrateleira: Situation.inativo,
    permiteConferirForaSequencia: Situation.inativo,
    visualizaTodasConferencias: Situation.inativo,
    permiteArmazenarForaSequencia: Situation.inativo,
    visualizaTodasArmazenagem: Situation.inativo,
    editaCarrinhoOutroUsuario: Situation.ativo,
    salvaCarrinhoOutroUsuario: Situation.ativo,
    excluiCarrinhoOutroUsuario: Situation.ativo,
    expedicaoEntregaBalcaoPreVenda: Situation.inativo,
  );
}
