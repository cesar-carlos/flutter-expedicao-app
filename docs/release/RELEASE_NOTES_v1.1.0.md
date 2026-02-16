# Release v1.1.0

## Correções

### Confiabilidade e Desempenho

- ✅ **Timeout e cleanup para consultas socket**
  - Implementado timeout de 10 segundos em consultas socket críticas
  - Garantido cleanup único de listeners em sucesso, erro e timeout
  - Arquivos: `separation_user_sector_consultation_repository_impl.dart`, `expedition_cart_consultation_repository_impl.dart`

- ✅ **Confiabilidade de sessão e navegação**
  - Validação explícita de usuário identificado (`codUsuario != null && codUsuario > 0`)
  - Mensagem clara de sessão inválida quando `codUsuario` é nulo
  - Setor nulo continua sem bloqueio de vínculo
  - Arquivos: `separation_screen.dart`, `separation_items_screen.dart`

- ✅ **Dados reais e simplificação no fluxo Próxima Separação**
  - Consulta de separação completa antes da navegação
  - Se consulta completa falhar, mostra erro controlado e não navega
  - Removido mapeamento manual com valores default
  - Reaproveitado `NextSeparationUserParams` já carregado (eliminando leitura duplicada)
  - Arquivo: `separation_screen.dart`

- ✅ **Integridade funcional do Add Cart**
  - Em nova leitura sem sucesso, limpa carrinho anterior e interrompe countdown
  - Garante que erro fique visível mesmo após leitura anterior bem sucedida
  - `_checkExistingCartRoute` retorna `Result` distinguindo "não encontrado" de erro
  - Em erro de consulta de percurso, não assume "não existe"; retorna erro explicitamente
  - Arquivo: `add_cart_viewmodel.dart`

### Arquitetura e UX

- ✅ **Consistência de arquitetura**
  - Eliminada duplicidade de `AddCartViewModel` (instanciado apenas em `app_router.dart`)
  - Mensagem de status permitidos corrigida: agora reflete apenas `AGUARDANDO` e `SEPARANDO`
  - Removidas chamadas de `dispose()` do `BarcodeScannerService` em ambos consumidores
  - Ownership de recursos compartilhados ajustado para não afetar outras telas
  - Arquivos: `add_cart_screen.dart`, `barcode_scanner_widget.dart`, `scan_input_processor.dart`, `separation_items_screen.dart`

## Testes

- ✅ Testes de regressão executados para validar as mudanças
- ✅ Todos os testes dos usecases modificados passaram
- ✅ Nenhum erro de lint introduzido no código principal

## Estatísticas

- **9 arquivos modificados**
- **292 linhas adicionadas, 182 linhas removidas** (líquido: +110 linhas)
- **0 erros** de compilação no código principal
- **0 warnings** de lint no código principal

## Observações

- Esta versão foca em melhorias internas de confiabilidade e desempenho
- Sem novas funcionalidades visíveis ao usuário final
- Código segue Clean Architecture e SOLID principles
- Regra de negócio preservada: usuário com setor nulo não sofre bloqueios
