import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';

class NextSeparationUserSuccess {
  final SeparationUserSectorConsultationModel? separation;
  final String message;

  const NextSeparationUserSuccess({this.separation, required this.message});

  factory NextSeparationUserSuccess.found(SeparationUserSectorConsultationModel separation) {
    return NextSeparationUserSuccess(separation: separation, message: 'Separação encontrada');
  }

  factory NextSeparationUserSuccess.notFound() {
    return const NextSeparationUserSuccess(
      separation: null,
      message: 'Não existe separação pendente para este usuário',
    );
  }

  bool get hasSeparation => separation != null;

  @override
  String toString() {
    return 'NextSeparationUserSuccess(hasSeparation: $hasSeparation, message: $message)';
  }
}
