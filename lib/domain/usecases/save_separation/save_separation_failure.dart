abstract class SaveSeparationFailure {
  final String message;
  final Exception? exception;

  const SaveSeparationFailure(this.message, [this.exception]);

  static SaveSeparationFailure invalidParams(String message) => _InvalidParams(message);

  static SaveSeparationFailure separationNotFound(int codEmpresa, int codSepararEstoque) =>
      _SeparationNotFound(codEmpresa, codSepararEstoque);

  static SaveSeparationFailure processoSeparacaoNotN(String currentValue) => _ProcessoSeparacaoNotN(currentValue);

  static SaveSeparationFailure situacaoNotSeparando(String currentSituacao) => _SituacaoNotSeparando(currentSituacao);

  static SaveSeparationFailure cartRouteNotFound(int codEmpresa, int codOrigem, String origem) =>
      _CartRouteNotFound(codEmpresa, codOrigem, origem);

  static SaveSeparationFailure updateCartRouteFailed(String message) => _UpdateCartRouteFailed(message);

  static SaveSeparationFailure networkError(String message, Exception exception) => _NetworkError(message, exception);

  static SaveSeparationFailure unknown(String message, Exception exception) => _Unknown(message, exception);

  @override
  String toString() => 'SaveSeparationFailure: $message';
}

class _InvalidParams extends SaveSeparationFailure {
  const _InvalidParams(super.message);
}

class _SeparationNotFound extends SaveSeparationFailure {
  const _SeparationNotFound(int codEmpresa, int codSepararEstoque)
    : super('Separação não encontrada para CodEmpresa: $codEmpresa, CodSepararEstoque: $codSepararEstoque');
}

class _ProcessoSeparacaoNotN extends SaveSeparationFailure {
  const _ProcessoSeparacaoNotN(String currentValue)
    : super('Processo de separação deve ser "N", mas está: $currentValue');
}

class _SituacaoNotSeparando extends SaveSeparationFailure {
  const _SituacaoNotSeparando(String currentSituacao)
    : super('Situação deve ser "SEPARANDO", mas está: $currentSituacao');
}

class _CartRouteNotFound extends SaveSeparationFailure {
  const _CartRouteNotFound(int codEmpresa, int codOrigem, String origem)
    : super('Carrinho percurso não encontrado para CodEmpresa: $codEmpresa, CodOrigem: $codOrigem, Origem: $origem');
}

class _UpdateCartRouteFailed extends SaveSeparationFailure {
  const _UpdateCartRouteFailed(super.message);
}

class _NetworkError extends SaveSeparationFailure {
  const _NetworkError(super.message, Exception super.exception);
}

class _Unknown extends SaveSeparationFailure {
  const _Unknown(super.message, Exception super.exception);
}
