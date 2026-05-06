# Release v2.1.0+1

## Resumo

Versão **2.1.0** com foco em **separação** (consulta ordenada e ciclo de atualização), **sincronização de picking** mais confiável e **fortalecimento de testes** (doubles reutilizáveis, use cases e ViewModels).

## Separação

- **Socket / consulta**: envio de `OrderBy` na consulta; ordenação **CodEmpresa ASC**, **CodSepararEstoque DESC**.
- **Listagem em tempo quase real**: **poll 10s**, **resync silencioso** da lista, **notificação** alinhada ao ciclo de poll e **logs** no fluxo de áudio para diagnóstico.

## Picking e qualidade

- Ajustes de **confiabilidade de sync** no picking.
- **Testes** adicionais de use cases e suites de integração / injeção, com manutenção de lint.
- **Test doubles** compartilhados, maior cobertura em fluxos de separação; **fake de áudio** no `AddCartViewModel` (evita flakiness com singleton).

## Tooling e documentação interna

- `fake_async` declarado em `dev_dependencies` (conformidade de lint).
- Reorganização de regras **agent/cursor** (apenas repositório; sem impacto funcional no app).

## Homologação sugerida

1. **Separação**: abrir lista, validar ordem dos registros e atualização periódica; alternar app para background e checar notificações conforme regra de produto.
2. **Picking**: sync após ações de rede; fluxos já exercitados na 2.0.0.
3. **Atualização automática** (build release): após publicar no GitHub com esta tag, validar download/instalação do APK.
