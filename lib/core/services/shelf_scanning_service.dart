import 'package:data7_expedicao/domain/models/separate_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

/// Serviço responsável pela lógica de escaneamento de prateleira
///
/// Responsabilidades:
/// - Determinar quando o escaneamento de prateleira é necessário
/// - Gerenciar o estado do último endereço escaneado
/// - Validar se deve mostrar o modal inicial
/// - Separar a lógica de negócio da UI
class ShelfScanningService {
  static final RegExp _controlCharsPattern = RegExp(r'[\n\r\t]');

  String? _lastScannedAddress;

  /// Obtém o último endereço escaneado
  String? get lastScannedAddress => _lastScannedAddress;

  /// Verifica se o usuário deve escanear prateleira
  bool requiresShelfScanning(UserSystemModel? userModel) {
    return userModel?.expedicaoObrigaEscanearPrateleira == Situation.ativo;
  }

  /// Verifica se deve escanear prateleira para o próximo item
  bool shouldScanShelf(SeparateItemConsultationModel nextItem, UserSystemModel? userModel) {
    if (!requiresShelfScanning(userModel)) return false;
    if (nextItem.endereco == null || nextItem.endereco!.isEmpty) return false;
    if (_lastScannedAddress == null) return true; // Primeiro item

    return _lastScannedAddress != nextItem.endereco; // Mudou de endereço
  }

  /// Verifica se deve mostrar o modal de escaneamento de prateleira na inicialização
  SeparateItemConsultationModel? shouldShowInitialShelfScan(
    List<SeparateItemConsultationModel> items,
    UserSystemModel? userModel,
    SeparateItemConsultationModel? Function() findNextItem,
  ) {
    if (!requiresShelfScanning(userModel)) return null;
    if (items.isEmpty) return null;

    final nextItem = findNextItem();
    if (nextItem == null) return null;
    if (nextItem.endereco == null || nextItem.endereco!.isEmpty) return null;

    return nextItem;
  }

  /// Atualiza o endereço escaneado
  void updateScannedAddress(String address) {
    _lastScannedAddress = address;
  }

  /// Remove apenas caracteres de controle enviados pelo leitor.
  ///
  /// Enderecos de prateleira podem conter letras, hifens e pontos
  /// (ex.: 01-A-2), entao a limpeza nao pode usar a regra numerica
  /// de codigo de barras de produto.
  String cleanScannedAddress(String address) {
    return address.replaceAll(_controlCharsPattern, '').trim();
  }

  /// Reseta o endereço escaneado
  void resetScannedAddress() {
    _lastScannedAddress = null;
  }

  /// Valida o endereço escaneado baseado no modo
  bool validateScannedAddress({
    required String scannedAddress,
    required String expectedAddress,
    required String expectedAddressDescription,
    required bool isManualMode,
  }) {
    if (isManualMode) {
      // Modo manual: validar contra enderecoDescricao (case insensitive)
      return scannedAddress.toLowerCase() == expectedAddressDescription.toLowerCase();
    } else {
      // Modo scan: validar contra endereco (case sensitive)
      return scannedAddress == expectedAddress;
    }
  }
}
