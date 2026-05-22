# Release v2.1.3+4

## Resumo

Versao **2.1.3** (build **+4**) com foco em confiabilidade do scanner Android, leitura por camera/QR e fluxo de scan de prateleira.

## Scanner e camera

- Scanner por camera movido para a camada de UI/presentation, removendo dependencia de `BuildContext` do dominio.
- `CameraBarcodeScanService.scan(BuildContext)` passa a centralizar a abertura da tela de camera e retorna `Result<String>` tipado.
- Erros de camera/QR passam a usar codigos explicitos: `SCAN_CANCELLED`, `EMPTY_BARCODE`, `PERMISSION_DENIED` e `SCANNER_ERROR`.
- Login por QR passou a mapear mensagens de usuario por codigo de erro, sem depender do texto interno da falha.

## Scanner por broadcast Android

- `BarcodeBroadcastStreamHandler` trata `onCancel` e re-listen de forma idempotente.
- Validacao clara para `action` e `extraKey` vazios no channel Android.
- Android 13+ mantem `Context.RECEIVER_EXPORTED` para compatibilidade com coletores externos.
- Avisos foram adicionados quando a configuracao usa defaults previsiveis de broadcast.

## Prateleira e picking

- Normalizacao de endereco de prateleira centralizada em `ShelfScanningService`, preservando letras, numeros, hifens e pontos.
- Fluxo legado de modal de prateleira foi unificado em `ShelfScanningModalV2`.
- Modais de prateleira passam a usar `ScannerModeCoordinator`, evitando listeners diretos concorrentes no mesmo `EventChannel`.
- `GenericBarcodeScanner` respeita `allowKeyboardInput` e permite injecao de `BarcodeScannerService` por construtor.

## Configuracao e robustez

- `ApiConfigEntity.toDomain()` ficou defensivo contra `scannerModeIndex` corrompido ou fora do range.
- Ajustes de lint/build Android para Kotlin/Gradle e testes Robolectric do broadcast.
- Cobertura ampliada para camera, QR login, scanner, prateleira, config e coordenadores.

## Homologacao sugerida

1. **QR login**: camera com sucesso, cancelamento, permissao negada e QR invalido.
2. **Coletor Android**: scan por broadcast com action/extra configurados e com defaults, validando logs e leitura.
3. **Prateleira**: enderecos com hifen e ponto, por broadcast e entrada manual/foco.
4. **Picking**: regressao de scan de produto, finalizacao e dialogos relacionados.
5. **Atualizacao**: publicar o APK desta release no GitHub e validar auto-update de um aparelho com build anterior.
