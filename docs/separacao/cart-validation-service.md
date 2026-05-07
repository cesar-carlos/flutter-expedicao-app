# CartValidationService

## Visao geral

`CartValidationService` centraliza regras de acesso e validacoes de
setor para carrinhos de separacao. A implementacao atual vive em:

`lib/domain/services/cart_validation_service.dart`

## Forma atual da API

Diferente da versao antiga da documentacao, o service atual nao e
estatico. Ele e construido com um repositorio:

```dart
CartValidationService({
  required BasicConsultationRepository<SeparateItemConsultationModel> repository,
})
```

Isso permite:

- mockar dependencias em testes
- reutilizar o mesmo service em camadas diferentes
- manter consulta de itens fora do widget

## Responsabilidades

### Permissoes por tipo de acao

Metodos sincronos:

- `canEditOtherUserCart(UserSystemModel? userModel)`
- `canSaveOtherUserCart(UserSystemModel? userModel)`
- `canDeleteOtherUserCart(UserSystemModel? userModel)`

Eles mapeiam diretamente as flags do `UserSystemModel`:

- `editaCarrinhoOutroUsuario`
- `salvaCarrinhoOutroUsuario`
- `excluiCarrinhoOutroUsuario`

### Regra basica de acesso

`canAccessCart(...)` libera o acesso quando:

- o usuario atual e o dono do carrinho
- ou o usuario possui permissao especial para aquela acao

Se `currentUserCode` for nulo, o acesso e negado.

### Validacao composta de acesso

`validateCartAccess(...)` recebe:

- `currentUserCode`
- `cart`
- `userModel`
- `accessType`

E devolve um `CartAccessValidationResult`, com:

- `canAccess`
- `reason`
- `cartOwnerName` quando fizer sentido

Os tipos atuais sao:

```dart
enum CartAccessType {
  edit,
  save,
  delete,
}
```

### Verificacao de itens para o setor

`hasItemsForUserSector(...)` consulta o repositorio e retorna `true`
quando ainda existe algum item:

- com `quantidadeSeparacao < quantidade`
- e sem setor ou do setor do usuario

Em caso de falha na consulta, o comportamento atual e permissivo:

```dart
return true;
```

Esse fallback evita bloquear o usuario por erro temporario de consulta,
mas registra warning via `AppLogger`.

## Uso atual na feature

O fluxo de entrada para a tela de picking usa esse service para:

1. validar se o usuario pode separar o carrinho
2. validar se ainda existem itens do setor dele

O fluxo de salvamento usa o mesmo service para validar se o usuario pode
salvar o carrinho, antes de chamar o use case de persistencia.

## Exemplo alinhado ao codigo atual

```dart
final validationResult = _cartValidationService.validateCartAccess(
  currentUserCode: _userModel!.codUsuario,
  cart: _cart!,
  userModel: _userModel!,
  accessType: CartAccessType.save,
);

if (!validationResult.canAccess) {
  return Failure(BusinessFailure(
    message: 'Voce nao tem permissao para salvar este carrinho.',
  ));
}
```

## O que mudou em relacao a docs antigas

- Nao usar `CartValidationService.metodo(...)` como API estatica.
- Nao documentar "metodos estaticos faceis de testar" como se ainda
  fosse o desenho atual.
- O service agora depende explicitamente de
  `BasicConsultationRepository<SeparateItemConsultationModel>`.
- O fallback de erro em `hasItemsForUserSector(...)` continua permitindo
  o fluxo e precisa ser considerado em debugging.
