# Release v2.1.4+5

## Resumo

Versao **2.1.4** (build **+5**) com foco em estabilizar o processo de release,
corrigir o CI e reduzir risco operacional na publicacao Android.

## CI e qualidade

- CI fixado em Flutter **3.41.9**, alinhado ao ambiente local de
  desenvolvimento.
- `actions/checkout` atualizado para **v5.0.1**, removendo o aviso de runtime
  Node.js 20 depreciado.
- Removido o uso de `cacheExtent` em `UsersListWidget`, evitando falha do
  `flutter analyze` em Flutter stable mais recente.

## Release Android

- `create-release.ps1` agora le a versao do `pubspec.yaml`, valida tag e notas,
  roda validacoes, gera artefatos versionados e cria hashes SHA-256.
- O script suporta publicacao via GitHub CLI com `-Publish` e protege o
  auto-update contra releases sem APK.
- Artefatos locais passam a ser gerados em `dist/release/vX.Y.Z+B/` com nome
  versionado.

## Assinatura e documentacao

- Build Android agora aceita assinatura de producao via `android/key.properties`.
- `REQUIRE_RELEASE_SIGNING=true` ou `-RequireReleaseSigning` faz o build falhar
  quando a assinatura de producao nao esta configurada.
- Documentacao de assinatura, processo de release, rollback, checklist de
  homologacao e seguranca do scanner broadcast foi atualizada.

## Homologacao sugerida

1. **Auto-update**: instalar build anterior e confirmar deteccao da
   `v2.1.4+5`.
2. **Release script**: validar `.\create-release.ps1 -SkipTests -SkipBuild` em
   maquina de desenvolvimento.
3. **CI**: confirmar execucao verde do workflow `CI` no GitHub para `main` e
   tag.
4. **Android signing**: validar que `-RequireReleaseSigning` bloqueia builds sem
   `android/key.properties` e passa quando o keystore real estiver configurado.
5. **Regressao rapida**: QR login, scanner broadcast, scan de prateleira e
   picking.
