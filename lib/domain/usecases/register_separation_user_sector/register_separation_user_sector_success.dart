class RegisterSeparationUserSectorSuccess {
  final String message;
  final String deviceIdentifier;

  const RegisterSeparationUserSectorSuccess({required this.message, required this.deviceIdentifier});

  factory RegisterSeparationUserSectorSuccess.registered({
    required int codUsuario,
    required String nomeUsuario,
    required int codSepararEstoque,
    required String deviceIdentifier,
  }) {
    return RegisterSeparationUserSectorSuccess(
      message: 'Usuário $nomeUsuario ($codUsuario) assumiu separação $codSepararEstoque',
      deviceIdentifier: deviceIdentifier,
    );
  }

  @override
  String toString() {
    return 'RegisterSeparationUserSectorSuccess(message: $message, deviceIdentifier: $deviceIdentifier)';
  }
}
