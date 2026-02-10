# Plano de Implementacao: Impressao Termica ESC/POS (NP-330N)

## 1. Objetivo

Implementar impressao termica em bobina 80mm para impressora na rede (print server NP330N), usando ESC/POS via TCP RAW (porta 9100), sem PDF e sem render de Widget para imagem.

## 2. Diagnostico da Estrutura Atual

Analise da base atual do projeto:

- Ja existe consulta de dados para impressao: `lib/data/repositories/expedition_item_print_consultation_repository_impl.dart`.
- Ja existe modelo de dominio com os campos de impressao: `lib/domain/models/expedition_item_print_consultation_model.dart`.
- O repositorio de consulta ja esta registrado no DI: `lib/di/locator.dart`.
- O fluxo operacional mais aderente para disparar impressao fica no fechamento de carrinho em `lib/ui/widgets/separate_items/cart_item_card.dart` (metodo `_onFinalizeCart`).
- O projeto ja possui infraestrutura reutilizavel para logs e resiliencia:
- `AppLogger`/`ILogger`: `lib/core/utils/app_logger.dart`, `lib/core/utils/i_logger.dart`
- `RetryPolicy`: `lib/core/network/retry_policy.dart`
- Configuracao persistida via Hive (`ApiConfig`): `lib/domain/models/api_config.dart`, `lib/data/datasources/config_service.dart`, `lib/data/models/api_config_entity.dart`

Conclusao: a base ja tem dados, DI, fluxo de negocio e componentes tecnicos para encaixar impressao sem ruptura arquitetural.

## 3. Decisoes Tecnicas

### 3.1 Protocolo e transporte

- Protocolo: ESC/POS
- Transporte: TCP RAW
- Porta padrao: 9100
- Impressora com IP fixo

### 3.2 Bibliotecas

Estado atual pesquisado no pub.dev:

- `esc_pos_utils_plus` (2.0.4): publicado ha ~17 meses.
- `esc_pos_printer` (4.1.0): publicado ha ~4 anos.
- `esc_pos_printer_plus` (0.1.1): publicado ha ~11 meses.

Decisao recomendada para este projeto:

- Usar `esc_pos_utils_plus` para gerar bytes ESC/POS (layout, QRCode, corte, imagem).
- Implementar transporte TCP proprio com `dart:io` (`Socket.connect`) para reduzir dependencia de pacote de transporte antigo e ganhar controle de timeout/log/retry.
- Manter uma abstracao de transporte para permitir troca futura (ex.: `esc_pos_printer_plus`) sem alterar use cases/UI.

## 4. Arquitetura Proposta (Aderente ao Projeto)

### 4.1 Configuracao da impressora

Manter configuracao de API separada da configuracao de impressoras.

Implementacao adotada:

- Persistencia dedicada em `SharedPreferences` para lista de impressoras e impressora padrao.
- Cadastro por `PrinterConfig` (`id`, `name`, `ip`, `port`).
- Descoberta de impressoras via rede (scan rapido e scan por faixa).

Arquivos principais:

- `lib/domain/models/printer_config.dart`
- `lib/data/datasources/printer_preferences_service.dart`
- `lib/infrastructure/services/printer_discovery_service.dart`
- `lib/domain/viewmodels/config_viewmodel.dart`
- `lib/ui/widgets/config/printer_config_form.dart`
- `lib/ui/screens/printer_config_screen.dart`
- `lib/ui/screens/config_screen.dart` (agora focada apenas em servidor)
- `lib/ui/widgets/app_drawer/app_drawer.dart` (menu dedicado de impressoras)

### 4.2 Dominio

Criar contratos e caso de uso focados em impressao:

- Criar `lib/domain/repositories/thermal_printer_repository.dart`
- Criar `lib/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart`
- Criar `lib/domain/usecases/print_expedition_ticket/print_expedition_ticket_success.dart`
- Criar `lib/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart`

Padrao de retorno:

- Usar `Result` (`core/results`) com `AppFailure` para erros de validacao/rede/negocio.

### 4.3 Infra/Data

Criar servicos tecnicos e implementacao concreta:

- Criar `lib/infrastructure/services/esc_pos_ticket_builder_service.dart`
- Criar `lib/infrastructure/services/thermal_printer_tcp_service.dart`
- Criar `lib/data/repositories/thermal_printer_repository_impl.dart`

Responsabilidades:

- `esc_pos_ticket_builder_service`: monta bytes ESC/POS com `esc_pos_utils_plus`
- `thermal_printer_tcp_service`: conecta, envia bytes, flush, encerra socket com timeout
- `thermal_printer_repository_impl`: orquestra envio + retry + mapeamento de erro

### 4.4 DI (GetIt)

Registrar no `lib/di/locator.dart`:

- servico de builder ESC/POS
- servico TCP da impressora
- repositorio de impressao
- use case `PrintExpeditionTicketUseCase`

### 4.5 UI

Ponto de integracao inicial recomendado:

- Apos sucesso de fechamento do carrinho (`_onFinalizeCart`) em `lib/ui/widgets/separate_items/cart_item_card.dart`.

Comportamento:

- Opcao "Salvar e Imprimir" (ou impressao automatica configuravel).
- Feedback visual de progresso e erro com `SnackBar`/dialog.
- Sem travar fluxo principal em caso de falha de impressao (operacao de impressao deve ser isolada da persistencia de fechamento).

## 5. Fluxo End-to-End de Impressao

1. Usuario finaliza carrinho.
2. Sistema executa `SaveSeparationCartUseCase`.
3. Em sucesso, dispara `PrintExpeditionTicketUseCase`.
4. Use case consulta itens para impressao via `BasicConsultationRepository<ExpeditionItemPrintConsultationModel>`.
5. Builder gera bytes ESC/POS (texto/colunas/qrcode/logo/corte).
6. Servico TCP envia bytes para `printerIp:printerPort`.
7. Sistema registra logs tecnicos (tempo, IP, status, erro quando houver).
8. UI apresenta status final (impresso ou falha de impressao).

## 6. Estrategia de Layout ESC/POS

Sem PDF e sem Widget->imagem. Layout logico ESC/POS:

- Cabecalho:
- logo (opcional, bitmap ESC/POS, max 576px)
- identificacao da separacao/carrinho
- data/hora
- Entidade/cliente
- Corpo:
- itens em colunas (produto, unidade, qtd, endereco se necessario)
- total de itens/quantidades
- Rodape:
- observacoes
- QRCode nativo (`generator.qrcode`)
- corte automatico (`generator.cut`)

Regras de compatibilidade:

- Preferir code table CP1252 para acentos.
- Limitar tamanho de imagem para evitar overflow de buffer.
- Ter fallback sem logo se imagem falhar.

## 7. Tratamento de Erros e Logs

Erros obrigatorios a tratar:

- Timeout de conexao
- `SocketException`
- Host unreachable
- Impressora desligada

Mapeamento sugerido:

- `TimeoutException` -> `NetworkFailure.connectionTimeout()`
- `SocketException` -> `NetworkFailure(message: ...)`
- Falha de bytes/layout -> `DataFailure` ou `BusinessFailure` conforme causa

Campos minimos de log por tentativa:

- `timestamp`
- `printerIp`
- `printerPort`
- `elapsedMs`
- `payloadBytes`
- `status` (success/failure)
- `errorType`
- `errorMessage`

Padrao sugerido:

- Log estruturado em linha unica via `AppLogger` para facilitar busca posterior.

## 8. Plano de Implementacao por Fases

### Fase 1 - Base tecnica de impressao

- Adicionar dependencias (`esc_pos_utils_plus`) e abstrair transporte TCP.
- Criar servicos de builder ESC/POS e envio TCP.
- Registrar DI no `locator`.

Entrega:

- POC funcional imprimindo ticket simples em 80mm via IP/porta.

### Fase 2 - Caso de uso + dados reais

- Implementar `PrintExpeditionTicketUseCase`.
- Integrar com repositorio de consulta `ExpeditionItemPrintConsultationRepositoryImpl`.
- Montar ticket real com campos do modelo existente.

Entrega:

- Impressao com dados reais da separacao/carrinho.

### Fase 3 - Configuracao de impressora no app

- Manter `ApiConfig` sem acoplamento com impressao.
- Persistir impressoras em fonte dedicada (`PrinterPreferencesService`).
- Criar formulario de configuracao de impressora.
- Adicionar descoberta de impressoras na rede.
- Adicionar "Testar impressora" no fluxo de configuracao.

Entrega:

- Configuracao persistida e validada em runtime.

### Fase 4 - Integracao de UX no fluxo operacional

- Integrar disparo de impressao no fechamento do carrinho.
- Implementar feedback de status para usuario.
- Definir comportamento "falha de impressao nao reverte fechamento".

Entrega:

- Fluxo completo de "finalizar + imprimir".

### Fase 5 - Hardening e observabilidade

- Aplicar retry/backoff controlado no envio TCP.
- Melhorar logs e padronizar codigos de falha.
- Ajustar layout para limites reais da NP-330N.

Entrega:

- Fluxo estavel em rede com erros previsiveis tratados.

## 9. Plano de Testes

### 9.1 Unitarios

- Builder ESC/POS: validar geracao de bytes para cabecalho, colunas, qrcode e corte.
- Mapeamento de falhas para `AppFailure`.
- Validacoes de parametros (IP invalido, porta fora de faixa, payload vazio).

### 9.2 Integracao (sem impressora fisica)

- Criar `ServerSocket` fake em loopback para simular porta 9100 e capturar bytes.
- Testar:
- sucesso de conexao/envio
- timeout de conexao
- host inexistente
- desconexao durante escrita

### 9.3 Integracao com fluxo de negocio

- Testar fechamento de carrinho + disparo de impressao.
- Garantir que falha de impressao nao anula fechamento salvo.

### 9.4 Homologacao em campo (NP-330N)

- Validar QRCode nativo.
- Validar corte automatico.
- Validar logo (max 576px).
- Validar tempo medio de impressao em rede real.

## 10. Criterios de Aceite

- Impressao 80mm via TCP 9100 funcionando com IP configuravel.
- Layout ESC/POS (texto, colunas, qrcode nativo, corte) sem PDF.
- Tratamento claro de timeout/socket/host unreachable/impressora offline.
- Logs com data/hora, IP, tempo de envio e erro.
- Configuracao da impressora persistida no app.
- Cobertura minima: testes unitarios + integracao de transporte.

## 11. Riscos e Mitigacoes

- Risco: incompatibilidade de comandos ESC/POS da NP-330N.
- Mitigacao: perfil de comandos por feature + fallback de recursos opcionais (logo/qrcode).

- Risco: buffers pequenos para imagem.
- Mitigacao: resize para max 576px e opcao de imprimir sem logo.

- Risco: instabilidade de rede.
- Mitigacao: timeout curto, retry com backoff, logs detalhados.

- Risco: acentuacao incorreta.
- Mitigacao: code table CP1252 e testes com texto real em PT-BR.

## 12. Referencias

- esc_pos_utils_plus: https://pub.dev/packages/esc_pos_utils_plus
- esc_pos_printer (historico): https://pub.dev/packages/esc_pos_printer
- esc_pos_printer_plus: https://pub.dev/packages/esc_pos_printer_plus

## 13. Auditoria da Implementacao (2026-02-09)

Resumo executivo:

- O fluxo principal "finalizar carrinho + imprimir" esta implementado e funcional.
- A configuracao de impressoras (CRUD, padrao, descoberta e teste) esta implementada.
- A base tecnica ESC/POS via TCP com retry e logs estruturados esta implementada.
- Ainda existem lacunas para considerar o plano 100% concluido (tests de fluxo, logo e homologacao de campo).

### 13.1 Fase 1 - Base tecnica de impressao

Status: concluida

Implementado:

- Dependencia `esc_pos_utils_plus` adicionada em `pubspec.yaml`.
- Builder ESC/POS em `lib/infrastructure/services/esc_pos_ticket_builder_service.dart`.
- Transporte TCP raw em `lib/infrastructure/services/thermal_printer_tcp_service.dart`.
- Abstracao e implementacao de repositorio em:
- `lib/domain/repositories/thermal_printer_repository.dart`
- `lib/data/repositories/thermal_printer_repository_impl.dart`
- Registro no DI em `lib/di/locator.dart`.

### 13.2 Fase 2 - Caso de uso + dados reais

Status: concluida

Implementado:

- Repositorio de consulta de dados de impressao:
- `lib/data/repositories/expedition_item_print_consultation_repository_impl.dart`
- Modelo de dados de impressao:
- `lib/domain/models/expedition_item_print_consultation_model.dart`
- Use case de impressao:
- `lib/domain/usecases/print_expedition_ticket/print_expedition_ticket_usecase.dart`
- Params e validacoes:
- `lib/domain/usecases/print_expedition_ticket/print_expedition_ticket_params.dart`
- Resultado da impressao:
- `lib/domain/models/thermal_print_result.dart`

Observacao:

- O arquivo `print_expedition_ticket_success.dart` previsto inicialmente nao foi criado, pois o retorno atual usa `ThermalPrintResult` dentro de `Result`.

### 13.3 Fase 3 - Configuracao de impressora no app

Status: concluida

Implementado:

- Modelo de configuracao da impressora:
- `lib/domain/models/printer_config.dart`
- Persistencia (lista e impressora padrao):
- `lib/data/datasources/printer_preferences_service.dart`
- Descoberta na rede (scan rapido e por faixa):
- `lib/infrastructure/services/printer_discovery_service.dart`
- ViewModel com CRUD, padrao, discovery e teste:
- `lib/domain/viewmodels/config_viewmodel.dart`
- UI de configuracao e acao de teste:
- `lib/ui/widgets/config/printer_config_form.dart`
- Tela dedicada de impressoras:
- `lib/ui/screens/printer_config_screen.dart`
- Navegacao dedicada no drawer:
- `lib/ui/widgets/app_drawer/app_drawer.dart`
- Tela `ConfigScreen` renomeada para contexto de servidor:
- `lib/ui/screens/config_screen.dart` com titulo "Configuracao do Servidor" e formulario apenas de servidor
- Internacionalizacao (i18n) da UI de impressoras:
- `lib/l10n/app_pt_BR.arb`, `lib/l10n/app_pt.arb`, `lib/l10n/app_en.arb`
- `lib/l10n/app_localizations*.dart`
- Ajuste visual de feedback:
- mensagens de sucesso/falha da UI de impressoras usando cores do tema (sem `Colors.green` hardcoded)

### 13.4 Fase 4 - Integracao de UX no fluxo operacional

Status: concluida no escopo atual

Implementado:

- Integracao apos sucesso do `SaveSeparationCartUseCase` em:
- `lib/ui/widgets/separate_items/cart_item_card.dart`
- Disparo assincrono da impressao (sem bloquear salvamento).
- Falha de impressao nao reverte fechamento.
- Feedback visual com `SnackBar` para sucesso/falha de impressao.
- Botao de impressao direta no card da listagem de separacoes em:
- `lib/ui/screens/separation_screen.dart`
- `lib/ui/widgets/separation/separation_card.dart`
- Fluxo do botao:
- resolve impressora padrao via `PrinterPreferencesService`
- dispara `PrintExpeditionTicketUseCase` com `codEmpresa` e `codSepararEstoque`
- exibe estado de progresso por card e feedback de sucesso/falha

Nota de escopo:

- Nao existe botao separado "Salvar e Imprimir"; o comportamento atual eh imprimir automaticamente quando ha impressora padrao cadastrada.

### 13.5 Fase 5 - Hardening e observabilidade

Status: parcial (em andamento)

Implementado:

- Retry/backoff via `RetryPolicy` no repositorio de impressao.
- Logs estruturados de impressao no repositorio:
- `lib/data/repositories/thermal_printer_repository_impl.dart`
- Logs estruturados de transporte TCP:
- `lib/infrastructure/services/thermal_printer_tcp_service.dart`
- Ticket de teste ESC/POS para validacao de conectividade:
- `buildPrinterTestTicketBytes(...)`.
- Hardening da consulta de itens de impressao:
- timeout de resposta com cleanup de listener em
- `lib/data/repositories/expedition_item_print_consultation_repository_impl.dart`
- Hardening da persistencia de impressoras:
- fallback seguro para JSON corrompido e deduplicacao de endpoints em
- `lib/data/datasources/printer_preferences_service.dart`
- Validacao anti-duplicidade no cadastro/edicao de impressoras (ip:porta):
- `lib/domain/viewmodels/config_viewmodel.dart`
- Compatibilidade ESC/POS aprimorada:
- code table global `CP1252` e suporte opcional a logo bitmap (com fallback sem quebra) em
- `lib/infrastructure/services/esc_pos_ticket_builder_service.dart`

Pendente para fechar fase:

- Homologacao de campo com NP-330N em rede real.
- Ajustes finos finais de layout e compatibilidade da impressora real (largura de logo, acentuacao em campo real e limites de buffer por modelo).

## 14. Testes - Estado Real

Implementado:

- Teste de integracao do TCP service com `ServerSocket` fake:
- `test/infrastructure/services/thermal_printer_tcp_service_test.dart`
- Cenarios cobertos:
- envio com sucesso
- payload vazio
- Testes unitarios do use case de impressao:
- `test/domain/usecases/print_expedition_ticket_usecase_test.dart`
- Cenarios cobertos:
- validacao de parametros invalidos
- retorno sem itens (not found)
- mapeamento de `DataError` para `NetworkFailure`
- caminho de sucesso com validacao da query e parametros enviados ao repositorio termico
- Testes unitarios do builder ESC/POS:
- `test/infrastructure/services/esc_pos_ticket_builder_service_test.dart`
- Cenarios cobertos:
- geracao de ticket de teste
- geracao de ticket com logo valida
- fallback quando logo invalida
- geracao de ticket de expedicao com item real
- erro quando lista de itens esta vazia
- Testes unitarios do repositorio de impressao:
- `test/data/repositories/thermal_printer_repository_impl_test.dart`
- Cenarios cobertos:
- validacao de ip/porta
- itens vazios
- sucesso de impressao de expedicao e de teste
- mapeamento de `TimeoutException`, `SocketException`, `StateError` e erro desconhecido
- retry com sucesso na segunda tentativa
- Testes unitarios do repositorio de consulta de impressao (socket):
- `test/data/repositories/expedition_item_print_consultation_repository_impl_test.dart`
- Cenarios cobertos:
- sucesso de parse de resposta
- sessao de socket indisponivel
- timeout de resposta
- Testes unitarios de regras de cadastro de impressora:
- `test/domain/viewmodels/config_viewmodel_printer_test.dart`
- Cenarios cobertos:
- bloqueio de duplicidade no cadastro
- bloqueio de duplicidade na edicao

Existente mas nao ativo:

- Teste de repositorio de consulta de impressao:
- `test/data/repositories/expedition_item_print_consultation_repository_integration_test.dart`
- Atualmente com `skip: true`.

Lacunas de teste:

- Testes de integracao do fluxo de negocio (salvar + imprimir sem rollback).
- Testes de integracao para cenarios de erro de rede adicionais (host inexistente e desconexao durante escrita).

## 15. Criterios de Aceite - Revisao de Status

- Impressao 80mm via TCP 9100 com IP configuravel: atendido.
- Layout ESC/POS sem PDF: atendido.
- Tratamento de timeout/socket/offline: atendido no nivel de repositorio/transporte.
- Logs com timestamp/IP/tempo/erro: atendido.
- Configuracao persistida no app: atendido.
- Cobertura minima unit + integracao de fluxo completo: parcial.

## 16. Proximos Passos Recomendados

### ✅ CONCLUÍDOS (2026-02-10)

- [x] **Expandir testes de transporte TCP**: Implementados testes para host inexistente, desconexão durante escrita, timeout, validações de IP/porta e medição de tempo. Arquivo: `test/infrastructure/services/thermal_printer_tcp_service_test.dart`

- [x] **Criar testes de fluxo completo**: Implementados testes que demonstram que falhas na impressão não afetam o salvamento do carrinho, com uso de `unawaited()` e tratamento de múltiplos cenários de falha. Arquivo: `test/domain/usecases/save_cart_with_print_test.dart`

- [x] **Definir fonte/configuracao de logo**: Implementado `CompanyLogoService` que carrega automaticamente o logo da empresa (`assets/images/log_se7e_black.png`). Integrado com `EscPosTicketBuilderService` via DI. Arquivos:
  - `lib/infrastructure/services/company_logo_service.dart`
  - `lib/infrastructure/services/esc_pos_ticket_builder_service.dart` (atualizado)
  - `lib/di/locator.dart` (registros atualizados)

### 🔄 PENDENTES

- [ ] **Ativar e estabilizar testes de integracao de consulta**: Testes atualmente `skip: true` por dependerem de servidor Socket.IO real. Arquivo: `test/data/repositories/expedition_item_print_consultation_repository_integration_test.dart`

- [ ] **Homologar em campo com NP-330N**: Validar QRCode, corte, acentuação, logo e desempenho em impressora física em rede real.

- [ ] **Definir opcao "Salvar e Imprimir"**: Decidir se o produto precisa de opção explícita além do auto print atual.

## 17. Historico de Alterações

### 2026-02-10
- ✅ Implementados testes adicionais de TCP (host inexistente, desconexão, timeout)
- ✅ Implementados testes de fluxo completo (salvar + imprimir sem rollback)
- ✅ Criado `CompanyLogoService` para carregar logo da empresa automaticamente
- ✅ Integrado logo service com `EscPosTicketBuilderService` e DI
- 📝 Documentação atualizada com novos testes e implementação de logo
