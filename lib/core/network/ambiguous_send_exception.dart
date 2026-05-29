/// Sinaliza uma falha ocorrida APOS o inicio do envio dos bytes, quando
/// nao e possivel garantir se a operacao foi concluida no destino (ex.:
/// os bytes ja foram entregues a impressora antes do erro).
///
/// Operacoes que lancam esta excecao NAO devem ser retentadas: um retry
/// poderia duplicar o efeito colateral (ex.: imprimir o mesmo ticket
/// duas vezes). Use com `RetryPolicy.shouldRetry` para curto-circuitar
/// o retry nesses casos.
class AmbiguousSendException implements Exception {
  final String message;
  final Object cause;
  final StackTrace? causeStackTrace;

  AmbiguousSendException(this.message, this.cause, [this.causeStackTrace]);

  @override
  String toString() => 'AmbiguousSendException: $message (cause: $cause)';
}
