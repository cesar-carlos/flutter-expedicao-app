# Release v2.1.5+6

## Resumo

Versao **2.1.5** (build **+6**) com o conjunto de correcoes e refatoracoes
acumulado desde a **2.1.4+5**, mais o build Android alinhado ao Flutter atual.

## Separacao e scanner

- Debounce de scan configuravel e tratamento de leitura fora de sequencia.
- Telas grandes de separacao, picking, consulta e impressao foram divididas em
  coordenadores, controllers e widgets menores.
- A checagem de atualizacao ficou separada da UI.

## Android

- App limitado a Android. A plataforma iOS foi removida.
- Gradle **9.3.1** e Android Gradle Plugin **9.1.0**.
- Kotlin passa a ser compilado pelo AGP (`android.builtInKotlin=true`). O plugin
  `kotlin-android` saiu do modulo do app.
- Plugins do Pub em outro disco mantem o diretorio de build local, evitando a
  falha de raizes diferentes no Windows.
- `desugar_jdk_libs` **2.1.5** para atender `flutter_local_notifications`.
- O lint do AGP 9.1 nao entra na publicacao: o worker nao carrega
  `LanguageVersionSettings`. A validacao Android fica nos testes unitarios.

## Release

- O processo de publicacao e `python create-release.py`.
- O auto-update continua exigindo tag `vX.Y.Z+B` e um APK anexado ao GitHub
  Release.

## Homologacao sugerida

1. **Auto-update**: instalar a `v2.1.4+5` e confirmar a deteccao da `v2.1.5+6`.
2. **Scanner**: debounce, leitura fora de sequencia, prateleira com hifen e ponto.
3. **Picking**: scan de produto, finalizacao e impressao.
4. **QR login**: sucesso, cancelamento, permissao negada e QR invalido.
