# Release v2.0.0+1

## Resumo

Marco **2.0.0** focado em **estabilidade**, **async seguro** (menos futures
descartados e melhor observação de erros), **rede/socket** e **parsing
defensivo** em modelos e repositórios — evolução ampla sobre a base da
v1.1.2+3 (~89 commits).

- Grande onda de correções em **lifecycle** (`mounted`), **diálogos** e
  **fluxos de picking/carrinho**
- **Socket**: heartbeat, reconnect, listeners e métricas mais previsíveis;
  **`SocketRequestHelper`** com adoção nos repositórios baseados em socket
- **Roteamento**: cache do **GoRouter** + `refreshListenable` (mitigação de
  problema crítico de navegação)
- **Modelos/DTOs**: helper **`JsonParse`** e rodadas de parsing defensivo;
  correções em `fromJson` de usuário e consultas
- **UI/widgets**: data grid (complexidade e `RangeError`), listas de usuários
  e carrinhos, AppBar/drawer, loading button
- **Infra**: logger com tag consistente, adapter GitHub, ESC/POS (`_formatPair`
  sem hífen solto no ticket)
- **Core**: bootstrap resiliente, métricas com auto-recovery, `AppFailure`,
  validadores e schemas (paginação, email)
- **i18n**: ARBs sincronizados e textos/guards alinhados
- `flutter analyze`: **No issues found** (na preparação desta release)

## Rede e socket

- **`SocketService`**: correções em registro duplicado de listeners e
  heartbeat duplicado
- **`SocketConnectionManager`**: races e stack traces nos erros; reconnect com
  trabalho assíncrono observado
- **`DioConfig`**: vazamento de memória e código morto
- **`SocketRequestHelper`** introduzido e aplicado de forma consistente nos
  repositórios socket-based
- Heartbeat e **`Timer.periodic`** ajustados para não interromper o ciclo do
  timer indevidamente

## Dados e modelos

- **`JsonParse`** e refator em múltiplos modelos (filtros, usuário, etc.)
- Correções em **`SeparateConsultationModel`**, DTOs de usuário e bugs de
  campos non-nullable sem fallback
- **`GithubRelease` / SHA**: falhas de parse melhor tratadas no adapter

## Apresentação e async

- Padrão recorrente: **observar** `Future`s de `showDialog`, bottom sheets,
  `showDatePicker`, init de view models, fluxo de login/registro e preferências
  de impressora
- **Picking**: fluxo e modais de prateleira com menos fire-and-forget;
  tratamento de áudio/notificação no debounce
- **App update** e diálogos relacionados endurecidos
- **Scanner**: isolamento de exceções em callbacks

## Widgets e telas

- **Data grid**: eliminação de O(n²) e prevenção de `RangeError` em `buildRow`
- **UsersList / CartsList** e widgets de socket/avatar/logo: bugs latentes
- **Telas**: lifecycle, `mounted`, diálogos duplicados ou travados
- **`AppRouter`**: casts inseguros em rotas com extras corrigidos

## Outros

- **Tema**: `isDarkMode` em modo system; persistência revisada
- **Constantes**: inconsistências e código morto
- **Use cases**: bugs em fluxos de carrinho/item e retry/catch genérico
- **Serviços**: sessão, eventos, áudio, notificação, foreground service
- **Telemetria / prefs**: `PrinterPreferencesService` — telemetria em
  `loadPrinters`; falhas inesperadas em `loadUserSession` logadas

## Observações

- **Major 2.0.0**: número de versão reflete marco de estabilidade e amplitude
  das mudanças internas; não há mudança de produto anunciada como “breaking”
  para o usuário final além da maior confiabilidade.
- Recomenda-se homologar em dispositivo real: login, separação (scan manual e
  broadcast), reconexão de rede, impressão térmica e fluxo de atualização do
  app (modo release).

### Plano de homologação sugerido

1. **Socket**: alternar Wi‑Fi/dados durante picking e confirmar recuperação sem
   estado inconsistente.
2. **Picking**: salvar/finalizar/cancelar com toques rápidos — mensagens de
   “em andamento” e ausência de dupla submissão.
3. **Impressão**: ticket sem artefato de formatação (hífen solto em pares).
4. **Auto-update** (release build): publicar este release no GitHub com APK e
   validar download/instalação.
