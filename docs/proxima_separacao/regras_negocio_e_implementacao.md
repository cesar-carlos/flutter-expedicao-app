# Processo "Proxima Separacao"

## Objetivo

Este documento descreve o comportamento atual do fluxo "Proxima
Separacao", usado para decidir qual separacao o usuario deve abrir ao
acionar o botao correspondente na tela de listagem.

O foco aqui e documentar o que o codigo faz hoje, sem carregar
suposicoes da versao anterior do fluxo.

## Onde o fluxo comeca

O disparo fica em:

- `lib/ui/screens/separation_screen.dart`

O FAB chama:

```dart
_findNextSeparation()
```

Esse metodo:

1. carrega a sessao do usuario
2. monta `NextSeparationUserParams`
3. executa `NextSeparationUserUseCase`
4. trata sucesso, ausencia de separacao ou falha
5. se houver separacao valida, consulta os dados completos antes de
   navegar para a tela de itens

## Pre-requisitos atuais

Os parametros sao representados por:

- `lib/domain/usecases/next_separation_user/next_separation_user_params.dart`

Hoje o fluxo exige:

- `codEmpresa > 0`
- `codUsuario > 0`
- `userSystemModel != null`
- `codSetorEstoque != null && codSetorEstoque > 0`

Se o usuario nao tiver setor valido, a tela nem prossegue com a busca e
mostra erro localmente. O use case tambem valida isso e retorna
`NextSeparationUserFailure.userWithoutSector()` como protecao adicional.

## Regras de negocio atuais

### Prioridade 1: voltar para uma separacao do proprio usuario

A primeira busca tenta encontrar uma separacao ja atribuida ao usuario
no setor dele.

Implementacao:

- `NextSeparationUserUseCase._findExistingSeparationWithPendingItems(...)`

O filtro de consulta usado hoje aplica:

- `CodEmpresa = params.codEmpresa`
- `CodUsuario = params.codUsuario`
- `CodSetorEstoque = params.codSetorEstoque`
- `SepararEstoqueSituacao` diferente de:
  - `CANCELADA`
  - `SEPARADO`
  - `EM PAUSA`
  - `BLOQUEADA`

Depois da consulta, a implementacao atual nao confia apenas na query
para saber se ha pendencia. Ela filtra o resultado em memoria com:

```dart
CheckSeparationUserSectorCompletionUseCase.hasPendingItems
```

Ou seja, a regra real de pendencia fica centralizada em:

- `quantidadeItensSetor > quantidadeItensSeparacaoSetor`
- ou `carrinhosAbertosUsuario == 'S'`

Se encontrar uma separacao com pendencia, o fluxo retorna ali mesmo.

Quando a consulta vem paginada, o use case continua avancando pagina por
pagina ate encontrar uma separacao realmente elegivel ou esgotar os
resultados. Isso evita falso `notFound` quando a primeira pagina so tem
trabalho concluido.

### Separacao concluida pelo setor do usuario nao volta

Na pratica, uma separacao em que o usuario nao tenha mais itens
pendentes nem carrinhos abertos deixa de ser elegivel na Prioridade 1.

Isso nao acontece por uma query dedicada de "setor concluido", mas pelo
filtro de pendencia descrito acima.

### Prioridade 2: procurar nova separacao disponivel

Se a Prioridade 1 nao retornar nada, o fluxo busca uma nova separacao
disponivel no setor do usuario.

Implementacao:

- `NextSeparationUserUseCase._findAndAssignNewSeparation(...)`

A query atual usa:

- `CodEmpresa = params.codEmpresa`
- `CodSetorEstoque = params.codSetorEstoque`
- `QuantidadeItensSetor > QuantidadeItensSeparacaoSetor`
- `CodUsuario IS NULL`
- situacao diferente de:
  - `CANCELADA`
  - `SEPARADO`
  - `EM PAUSA`
  - `BLOQUEADA`

Se houver candidata, o use case tenta registrar a atribuicao via:

- `RegisterSeparationUserSectorUseCase`

No sucesso, ele devolve a separacao com `codUsuario` e `nomeUsuario`
atualizados no retorno.

### Retry de atribuicao

Se a atribuicao falhar, o fluxo tenta novamente ate 3 vezes.

Implementacao:

- `NextSeparationUserUseCase._findAndAssignNewSeparationPaged(...)`

No caminho paginado, a implementacao atual registra as separacoes ja
tentadas e evita repetir a mesma candidata dentro da mesma execucao do
fluxo.

Se existirem candidatas, mas nenhuma atribuicao conseguir ser gravada, o
use case agora retorna falha explicita de atribuicao em vez de colapsar
o caso para `notFound`.

### Fallback para erro SQL com paginacao

O use case tambem tem um comportamento especifico para alguns erros de
consulta:

- se detectar erro SQL, `offset` ou problema de `fetch/statement`
- ele refaz a busca sem paginacao

Esse fallback existe tanto para a Prioridade 1 quanto para a Prioridade
2.

## Fluxo de abertura na UI

Quando o use case encontra uma separacao, a `SeparationScreen` ainda nao
navega direto para a tela de itens.

Passos atuais:

1. valida se `separation.codUsuario == params.codUsuario`
2. consulta os dados completos com `GetSeparationConsultationUseCase`
3. so depois chama `context.push(AppRouter.separateItems, ...)`

Esse detalhe e importante porque o retorno do use case usa
`SeparationUserSectorConsultationModel`, mas a tela de itens abre com
os dados completos da separacao.

## Verificacao de vinculo do usuario com a separacao

O controle de acesso para abrir uma separacao ja existente fica
centralizado em:

- `ResolveSeparationUserLinkUseCase`

Regras atuais:

- usuario com setor:
  - so pode abrir separacao vinculada a ele
- usuario sem setor:
  - mantem permissao administrativa

O comportamento do resolver e:

1. se `codUsuariosSeparacao` vier preenchido na listagem, usa
   `contains(codUsuario)`
2. se vier vazio, faz fallback para
   `CheckSeparationUserSectorLinkUseCase`

Esse mesmo use case e reutilizado em:

- `SeparationScreen._onSeparationTap()`
- `SeparationItemsScreen._initializeAfterFirstFrame()`
- `SeparationItemsScreen._onAddCart()`

## Incluir carrinho

O documento antigo estava perto, mas faltava uma regra relevante.

Hoje, para incluir carrinho em `SeparationItemsScreen._onAddCart(...)`,
o fluxo valida tudo isso:

1. consulta novamente a separacao no servidor com
   `GetSeparationConsultationUseCase`
2. verifica se a situacao atual permite incluir carrinho
3. verifica vinculo do usuario com `ResolveSeparationUserLinkUseCase`
4. verifica se o setor do usuario ja foi concluido com
   `CheckSeparationUserSectorCompletionUseCase`
5. so depois navega para `AppRouter.addCart`

Quando a tela de adicionar carrinho retorna sucesso, a implementacao
atual reconsulta os carrinhos da separacao e tenta abrir exatamente o
carrinho adicionado, usando `codCarrinho` e `codCarrinhoPercurso`, em
vez de reabrir heuristica de "carrinho mais recente".

### Situacoes permitidas para incluir carrinho

Implementacao:

```dart
separation.situacao == ExpeditionSituation.aguardando ||
separation.situacao == ExpeditionSituation.separando
```

### Regra adicional importante

Mesmo que a separacao esteja em situacao valida e vinculada ao usuario,
o app bloqueia incluir carrinho quando o setor daquele usuario ja esta
concluido na separacao.

Essa checagem fica em:

- `CheckSeparationUserSectorCompletionUseCase`

Ela olha se ainda existe:

- item pendente no setor
- ou carrinho aberto do usuario

Se nao houver mais pendencia, a UI informa que o setor ja esta
concluido e impede novos carrinhos.

## Carrinho de outro usuario

As permissoes de separar, salvar e cancelar carrinho continuam
centralizadas em:

- `lib/domain/services/cart_validation_service.dart`

As regras atuais sao:

- dono do carrinho sempre pode agir
- outro usuario depende da permissao correspondente no
  `UserSystemModel`

Permissoes usadas:

- `editaCarrinhoOutroUsuario`
- `salvaCarrinhoOutroUsuario`
- `excluiCarrinhoOutroUsuario`

Essas validacoes sao usadas em:

- `lib/ui/widgets/separate_items/cart_item_card.dart`
- `lib/presentation/viewmodels/card_picking_viewmodel.dart`

## Camadas e arquivos principais

- Presentation:
  - `lib/ui/screens/separation_screen.dart`
  - `lib/ui/screens/separation_items_screen.dart`
- Domain:
  - `lib/domain/usecases/next_separation_user/next_separation_user_usecase.dart`
  - `lib/domain/usecases/next_separation_user/next_separation_user_params.dart`
  - `lib/domain/usecases/next_separation_user/next_separation_user_success.dart`
  - `lib/domain/usecases/next_separation_user/next_separation_user_failure.dart`
  - `lib/domain/usecases/register_separation_user_sector/register_separation_user_sector_usecase.dart`
  - `lib/domain/usecases/resolve_separation_user_link/resolve_separation_user_link_usecase.dart`
  - `lib/domain/usecases/check_separation_user_sector_link/check_separation_user_sector_link_usecase.dart`
  - `lib/domain/usecases/check_separation_user_sector_completion/check_separation_user_sector_completion_usecase.dart`
- Data:
  - `lib/data/repositories/separation_user_sector_consultation_repository_impl.dart`

## Observacoes de implementacao

### Repositorio de consulta

`SeparationUserSectorConsultationRepositoryImpl` tem um comportamento
proprio:

- espera ate 1.5s se o socket estiver desconectado no inicio
- se continuar desconectado, lanca erro de dados

Isso ajuda a explicar por que algumas buscas nao falham imediatamente em
cenarios de reconexao.

### Tipos de falha do fluxo

O use case hoje pode retornar falhas especificas como:

- `userWithoutSector`
- `invalidParams`
- `assignmentFailed`
- `socketDisconnected`
- `networkError`
- `serverError`
- `unknownError`

Esses tipos vivem em:

- `lib/domain/usecases/next_separation_user/next_separation_user_failure.dart`

## Resumo pratico

- O usuario com setor sempre tenta retomar primeiro o que ja esta no
  nome dele.
- So pega nova separacao quando nao ha mais pendencia na atual.
- Nova separacao precisa ser atribuida antes de abrir.
- A UI reconsulta a separacao completa antes de navegar.
- Abrir separacao e incluir carrinho dependem de vinculo com o usuario.
- Incluir carrinho tambem e bloqueado quando o setor do usuario ja foi
  concluido.

## Diferencas em relacao ao documento anterior

- Texto sem encoding quebrado.
- Prioridade 1 documentada como filtro em memoria apos a consulta, que e
  o comportamento real do codigo.
- Retry descrito sem afirmar que sempre busca uma separacao diferente.
- Fluxo de abertura atualizado para incluir
  `GetSeparationConsultationUseCase`.
- Regra de setor concluido em "Incluir Carrinho" documentada.
