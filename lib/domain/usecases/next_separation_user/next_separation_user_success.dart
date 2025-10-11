import 'package:exp/domain/models/separation_user_sector_consultation_model.dart';

/// Resultado de sucesso ao buscar a próxima separação para o usuário
class NextSeparationUserSuccess {
  final SeparationUserSectorConsultationModel? separation;
  final String message;

  const NextSeparationUserSuccess({this.separation, required this.message});

  /// Cria um resultado de sucesso quando uma separação é encontrada
  factory NextSeparationUserSuccess.found(SeparationUserSectorConsultationModel separation) {
    return NextSeparationUserSuccess(separation: separation, message: 'Separação encontrada');
  }

  /// Cria um resultado de sucesso quando nenhuma separação está disponível
  factory NextSeparationUserSuccess.notFound() {
    return const NextSeparationUserSuccess(
      separation: null,
      message: 'Não existe separação pendente para este usuário',
    );
  }

  /// Indica se uma separação foi encontrada
  bool get hasSeparation => separation != null;

  @override
  String toString() {
    return 'NextSeparationUserSuccess(hasSeparation: $hasSeparation, message: $message)';
  }
}
