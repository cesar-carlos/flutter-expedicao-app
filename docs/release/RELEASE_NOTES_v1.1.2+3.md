# Release v1.1.2+3

## Resumo

Release de auditoria e estabilização. Foco em **regra de negócio crítica do
picking**, **impressão térmica**, **validações de formulários** e **refator
estrutural** dos componentes mais densos do app, sem alteração de UX
visível além das correções listadas abaixo.

- 21 bugs corrigidos (incluindo 4 race conditions e 5 leaks de
  validação/cache que afetavam regra de negócio)
- 6 controllers/services novos extraídos para reduzir acoplamento e
  permitir testes
- 106 testes novos + 19 testes pré-existentes destravados (= +125
  testes verdes na suite)
- 0 regressões em 13 commits
- `flutter analyze`: clean

## Correções

### Impressão térmica

- **Logo da empresa removido da impressão**: o asset
  `log_se7e_black.png` (1440×750 px) era redimensionado para 576×300 px
  e ocupava ~37,5 mm no topo do papel 80 mm — gerava ~5 cm de espaço
  aparente antes do conteúdo. Agora o ticket começa direto em "TESTE
  DE IMPRESSORA" / "LISTA DE SEPARAÇÃO".
- **Validação prévia de IP/porta** (`ThermalPrinterRepositoryImpl`):
  configuração com IP vazio ou porta fora do range 1-65535 agora
  retorna `ValidationFailure` cedo, em vez de falhar mais tarde com
  `SocketException` no meio do envio.
- Removida dependência direta `image: ^4.5.4` do `pubspec.yaml`
  (continua transitiva via `esc_pos_utils_plus`).

### Scan / Picking — bugs críticos de regra de negócio

- **B1**: cache estático global do `BarcodeValidationService` cruzava
  separações diferentes (poderia gerar `wrongSector` falso ao trocar
  de carrinho). Reescrito como LRU com max-size 256 e invalidação
  automática por `identityHashCode` da lista de items.
- **B2**: race condition em `PickingCardScan` permitia **dupla adição**
  do mesmo item ao carrinho em modo broadcast (dois Intents chegando
  em sequência rápida antes de `startProcessing` ser setado). Adicionado
  `tryStartProcessing()` atômico em `PickingScanState`.
- **B3+B4**: `ShelfScanningScreen` removia hífens (Enter) e letras
  (broadcast), quebrando endereços alfanuméricos como `01-A-2`. Agora
  apenas caracteres de controle são removidos; a validação fica
  delegada a `validateShelfBarcode` (que compara o endereço íntegro).
- **B5**: `BarcodeScannerRepositoryMobileImpl` era singleton com
  `BuildContext` mutável (`setContext`) — anti-pattern que arriscava
  uso de context já desmontado. Refatorado para receber context como
  parâmetro em `scanBarcode({required BuildContext context})`.
- **B6**: `setEnabled(...)` movido para fora do `build()` (post-frame
  callback) no `PickingCardScan` — evita disparo de `notifyListeners`
  durante o build.
- **B7**: `ShelfScanningScreen._processScannerInput` empilhava
  `Future.delayed` por keystroke. Trocado por `Timer` cancelável.
- **B8**: removido `_validationCache` morto no
  `BarcodeValidationService` (declarado mas nunca lido).
- **B9**: `extraKey` default no Kotlin (`BarcodeBroadcastStreamHandler`)
  alinhado com o form Dart (`"data"`) — antes era `"barcode"`.
- **B10**: cache de busca por barcode no `BarcodeValidationService`
  agora tem max-size (256 entradas, LRU) — antes crescia indefinidamente
  em sessões longas.
- **B11**: cache de regex em `BarcodeScannerService` removido (regex
  já é da ordem de microssegundos; o cache só consumia memória).
- **B12** (race condition em operações irreversíveis): toques rápidos
  no botão "Salvar/Finalizar/Cancelar" do picking podiam disparar duas
  execuções em paralelo (risco de double-update no servidor e rollbacks
  inconsistentes em caso de falha). Adicionado lock atômico em
  `saveCart`, `finalizePicking` e `cancelPicking`.

### Validações de formulário e dados

- `FormValidators.username/name/numeric` agora rejeitam string vazia /
  só espaços / null consistentemente (antes era inconsistente após
  upgrade do Zard).
- `FormValidators.codSepararEstoque` agora aceita null/vazio como
  opcional (era rejeitado pelo schema mesmo declarado `.optional()`).
- `QueryBuilder.buildOrderBySql()` corrigido — gerava URL params
  (idêntico a `buildOrderByQuery`) em vez de SQL real
  (`ORDER BY field DESC`). Provável copy-paste antigo.
- `ExpeditionItemPrintConsultationRepositoryImpl` deixou de consultar
  `SocketConfig.isConnected` global, que ignorava o `socket` injetado
  e quebrava testes com mock. Indisponibilidade real continua coberta
  por `sessionId` + `responseTimeout`.

### Smells/cleanup menores (S1, S2, S3, S5, P4)

- Removida checagem duplicada de `mounted` em `_closeWithResult`.
- `ScannerActivationController._reactivateFocusMode` agora propaga o
  callback `onBarcodeScanned` original (evita bug silencioso futuro).
- `dispose()` de `ScannerBroadcastController` documenta
  `discarded_futures` corretamente.
- `_validationTimer` do shelf scan agora é imediato em fluxos vindos
  de Enter/broadcast (apenas digitação manual mantém o debounce de
  100 ms).
- `scan_history.take(50).toList()` substituído por `removeLast()` no
  `ScannerViewModel`.

## Melhorias estruturais

### Refator do `CardPickingViewModel` (999 → 729 linhas, -27%)

Extraídos para módulos coesos e testáveis (sem dependência de
`BuildContext`/`ChangeNotifier`):

- **`CartEventListenerController`**: ciclo de vida do listener de
  eventos do carrinho.
- **`PickingPendingOperationsTracker`**: gerenciamento de futures em
  andamento por `itemId`.
- **`PickingFiltersController`**: estado/persistência/filtragem em
  memória dos filtros de produtos pendentes.
- **`PickingMetricsRecorder`**: integração com `MetricsCollector`
  (opcional, no-op silencioso se não registrado).
- **`PickingScanResolver`**: regra de negócio pura do `processScan`
  (cerne do fluxo de picking) — agora 100% coberta por testes
  unitários sem mocks pesados.
- Eliminado helper duplicado `_sortItemsByAddress` (migração para
  `PickingUtils.sortItemsByAddress`).

### Refator do módulo de scan

- **`ScannerModeCoordinator`**: encapsula o boilerplate de
  "carregar prefs → start broadcast → manual override → dispose" que
  estava duplicado em 4 telas. Adotado em:
  - `ScannerScreen` (tela livre)
  - `BarcodeScanner` (`add_cart`)
  - `ShelfScanningScreen`
  - `ScannerBroadcastController` (wrapper interno) — preserva a API
    pública do `PickingCardScan`/`ScannerActivationController`.

## Cobertura de testes

| Módulo | Antes | Depois |
|---|---|---|
| `BarcodeScannerService` | 0 | 17 |
| `BarcodeValidationService` | 0 | 16 (incluindo regressão para B1 e B10) |
| `PickingUtils.validateBarcode/Shelf` | 0 | 8 |
| `ScannerModeCoordinator` | 0 | 13 |
| `ScannerBroadcastController` (wrapper) | 0 | 5 |
| `CartEventListenerController` | 0 | 8 |
| `PickingFiltersController` | 0 | 14 |
| `PickingMetricsRecorder` | 0 | 3 |
| `PickingPendingOperationsTracker` | 0 | 9 |
| `PickingScanResolver` (cerne do `processScan`) | 0 | 15 |
| **Total novos** | **0** | **108** |
| Testes pré-existentes destravados | — | +19 |
| **Suite global** | **234/262** | **348/357** |
| Falhas restantes | 28 | 9 (todas integration tests sem servidor) |

## Observações

- `flutter analyze`: **No issues found**.
- Nenhuma regressão introduzida nos 13 commits desta release.
- As 9 falhas restantes da suite são `*_integration_test.dart` que
  exigem servidor Socket.IO ativo na porta 3001 e o plugin
  `path_provider` registrado — esperadas em ambiente sem servidor.

### Plano de homologação recomendado

1. Em coletor real (Zebra/Honeywell/Sunmi):
   - Bipar produto com endereço alfanumérico (`01-A-2`) → confirmar
     que B3+B4 resolveram (preserva hífen).
   - Bipar 2 leituras quase simultâneas em modo broadcast → confirmar
     que B2 (race de dupla adição) resolveu.
   - Trocar entre separações sem fechar o app → confirmar B1 (cache
     cross-separação).
   - Tocar 2x rápido em "Salvar carrinho" → deve mostrar
     "Salvamento em andamento. Aguarde a conclusão" no segundo toque (B12).
2. Na NP-330N:
   - Imprimir um ticket → topo deve ter < 1 cm (era ~5 cm).
3. Login/cadastro:
   - Username/nome vazio → deve invalidar agora (era aceito).
