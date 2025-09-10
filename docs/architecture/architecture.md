# Arquitetura recomendada — resumo e plano de aplicação

Este documento resume as recomendações oficiais do Flutter (conceitos, guia e estudo de caso) e propõe uma estrutura prática, contratos e passos iniciais para aplicar em projetos reais.

## 1. Objetivo

- Fornecer uma referência curta e aplicável para organizar o código do app.
- Traduzir os conceitos do site do Flutter para uma estrutura inicial que você possa aplicar neste repositório.

## 2. Princípios chave

- Separação de responsabilidades (UI / Domain / Data).
- Código testável e desacoplado (injeção de dependência, interfaces/abstrações).
- Camadas pequenas e explicitamente definidas.
- Preferir composição sobre herança.

## 3. Camadas propostas

- UI Layer
  - Widgets, screens, e widgets reaproveitáveis.
  - Somente apresentação e ligação com o estado (recebe ViewModels/Controllers).
- Domain / Business Logic Layer
  - Regras de negócio e casos de uso (use-cases / services).
  - Interfaces (por exemplo: AuthRepository, TodosRepository).
- Data Layer
  - Implementações concretas de repositórios (APIs, SQLite, cache).
  - Mapeamento de modelos (DTOs ↔ domain models).
- Composition Root / DI
  - Configuração de dependências (get_it, injectable ou Riverpod ProviderScope).

## 4. Estrutura de pastas sugerida

```
lib/
  src/
    ui/
      screens/
      widgets/
    domain/
      models/
      usecases/
    data/
      dtos/
      repositories/
      datasources/
    core/
      errors/
      network/
    di/    # composition root: registradores de dependência
    main.dart
```

> Nota: para projetos pequenos, `src/` é opcional; objetivo é reduzir acoplamento e facilitar navegação.

## 5. Gerenciamento de estado (opções)

- Provider / ChangeNotifier: simples, integrado, bom para apps pequenos e ensino.
- Riverpod: segurança maior, testável e escalável.
- BLoC (flutter_bloc): se quiser eventos/streams e separação clara de eventos/estado.

Escolha uma família e aplique consistentemente.

## 6. Injeção de dependência

- get_it (service locator) + injectable (geração) é uma combinação popular.
- Riverpod também resolve DI com ProviderScope e providers declarativos.

## 7. Testes recomendados

- Unit tests: use-cases, validadores, transformações de dados.
- Widget tests: comportamento de widgets isolados (ex.: botão incrementa contador).
- Integration tests: fluxo crítico (login, navegação principal).

Exemplo rápido de teste de widget (descrição):

- Verificar que ao tocar no `FloatingActionButton` o contador incrementa.

## 8. Contrato mínimo (2–3 bullets)

- Inputs: widgets recebem ViewModel/State via provider/provider parameter.
- Outputs: ViewModel expõe streams/notifiers ou propriedades (state/result/error).
- Erros: camada de UI apresenta mensagens a partir de objetos de erro do core/errors.

## 9. Edge cases a proteger desde o início

- Falhas de rede / timeouts.
- Respostas inválidas do backend (validação de DTOs).
- Estados de carregamento e erro bem definidos.
- Recursos nulos/ausentes.

## 10. Plano de refatoração incremental (para seu projeto atual)

1. Criar pastas base (`ui/`, `domain/`, `data/`, `di/`) sob `lib/`.
2. Mover lógica do contador para um `CounterViewModel` ou `CounterNotifier` usando Provider.
3. Registrar ViewModel no composition root e injetar na `MyHomePage`.
4. Adicionar um teste de widget para o contador.

## 11. Exemplo mínimo (pseudo-passos)

- Criar `lib/di/locator.dart` com `GetIt` ou `lib/di/providers.dart` com Riverpod.
- `lib/ui/screens/home_screen.dart` recebe o provider e constrói UI.
- `lib/domain/counter/counter_notifier.dart` contém a lógica do contador e métodos testáveis.

## 12. Próximos passos sugeridos (posso implementar)

- Gerar o esqueleto das pastas e mover `main.dart` para usar DI e um `CounterNotifier`.
- Implementar exemplo usando `Provider` (simples) ou `Riverpod` (recomendado para escalabilidade).
- Adicionar 2 testes: unit (counter) + widget (UI interage com counter).

## 13. Referências

- Links oficiais do Flutter (guide & case study):
  - Conceitos, guia e estudos de caso na documentação oficial do Flutter.

---

Se quiser, eu já crio o esqueleto do projeto (`lib/` com pastas e arquivos mínimos), e um exemplo usando `Provider` ou `Riverpod` e os testes correspondentes — diga qual abordagem prefere e eu prosseguo.
