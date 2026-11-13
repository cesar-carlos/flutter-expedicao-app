# Documentacao

Esta pasta guarda o que o codigo do coletor nao deixa obvio: operacao
de release, atualizacao do app e regras de negocio da separacao.

Arquitetura, estilo e padroes ficam em `.cursor/rules/`. O `README.md`
da raiz cobre instalacao e execucao.

Contrato com o servidor (HTTP + Socket.IO) nao mora aqui. Fonte:

`D:\Developer\Node\data7-api-pix Campo\docs`

Comece por `docs/comunicacao.md` e `docs/socket/protecoes-cliente.md`.
Plano futuro (kick, RCSI, breaking): `docs/feature/protecao-base-e-emergencia.md`.
Estado local, divergencias e melhorias pendentes de HTTP e Socket.IO:
[integracao com o servidor](socket.md).

## Pastas

```text
docs/
|- README.md                 este indice
|- socket.md                 integracao HTTP/Socket.IO e pendencias locais
|- app-update.md             atualizacao automatica via GitHub
|- scanner-broadcast-android.md
|- separacao/                regras de picking no coletor
|- proxima_separacao/        oferta da proxima separacao
`- release/                  processo e notas de versao
```

## Operacao

- [Processo de release](release/RELEASE_PROCESS.md)
- [Atualizacao automatica](app-update.md)
- [Scanner por broadcast no Android](scanner-broadcast-android.md)

As notas de cada versao ficam em `release/RELEASE_NOTES_vX.Y.Z+B.md`.
O `create-release.py` exige o arquivo da versao que esta no
`pubspec.yaml`.

## Scripts

Script documentado neste repositorio e escrito em Python. O release
usa `python create-release.py`.

## Separacao

- [Integracao HTTP e Socket.IO neste coletor](socket.md)
- [Separacao por setor](separacao/README.md)
- [Proxima separacao](proxima_separacao/regras_negocio_e_implementacao.md)
