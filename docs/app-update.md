# Atualizacao automatica

Em build de release, o app consulta o ultimo release do GitHub, oferece
o APK e abre o instalador do Android. Publicar a versao segue
[o processo de release](release/RELEASE_PROCESS.md).

## Ambiente

No `.env` da raiz:

```env
GITHUB_OWNER=organizacao-ou-usuario
GITHUB_REPO=nome-do-repositorio
GITHUB_TOKEN=
```

`GITHUB_TOKEN` so e necessario em repositorio privado. O app carrega o
`.env` na inicializacao. Se o arquivo faltar, a verificacao informa que
`GITHUB_OWNER` ou `GITHUB_REPO` nao estao configurados e o restante do
app continua.

A tag do release precisa ser `vX.Y.Z+B`, igual ao `version` do
`pubspec.yaml`, com um `.apk` anexado e o release publicado.

## Comportamento

- A verificacao automatica roda so em release, cerca de 2 segundos
  depois da abertura.
- O resultado fica em cache por 1 hora. Tocar na versao no drawer
  ignora o cache.
- Falha de rede na verificacao automatica nao bloqueia o app. Na
  verificacao manual, o erro aparece para o usuario.
- O Android precisa da permissao `REQUEST_INSTALL_PACKAGES`, ja
  declarada no manifesto. A instalacao pede confirmacao do usuario.

## Quando a atualizacao nao aparece

- A versao publicada nao e maior que a do app instalado.
- O app esta em debug.
- O release esta como rascunho, ou o APK nao foi anexado.
- `GITHUB_OWNER` ou `GITHUB_REPO` nao batem com o repositorio.
