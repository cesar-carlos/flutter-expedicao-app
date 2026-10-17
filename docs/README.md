# Documentacao

Esta pasta guarda o que o codigo nao deixa obvio: operacao de release,
atualizacao do app e regras de negocio da separacao.

Arquitetura, estilo e padroes ficam em `.cursor/rules/`. O `README.md`
da raiz cobre instalacao e execucao.

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

- [Separacao por setor](separacao/README.md)
- [Proxima separacao](proxima_separacao/regras_negocio_e_implementacao.md)
