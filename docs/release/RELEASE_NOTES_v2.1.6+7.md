# Release v2.1.6+7

## Resumo

Versao **2.1.6** (build **+7**) corrige o APK de release que ficava preso na
splash do Android. O debug continuava abrindo porque nao passa pelo R8.

## Android

- O `shared_preferences_android` 2.5.x chama o Kotlin por JNI. No release o R8
  renomeava `kotlin.coroutines.Continuation` e classes vizinhas, a leitura das
  preferencias estourava antes do `runApp` e a splash do sistema nao saia.
- `android/app/proguard-rules.pro` preserva essas classes. O mapeamento do
  release confirma que os nomes originais permanecem.

## CI

- Removido `android-actions/setup-android@v3`. O pacote legado `tools` saiu do
  SDK da Google e o job `android` falhava em cerca de 17s. O runner ja traz o
  Android SDK.
- O job Android deixa de rodar `:app:lintDebug`. O worker de lint do AGP 9.1
  nao carrega `LanguageVersionSettings`. A validacao continua em
  `:app:testDebugUnitTest`.

## Homologacao sugerida

1. **Splash**: instalar este APK num aparelho que travava na splash e confirmar
   que a tela azul do app abre.
2. **Auto-update**: instalar a `v2.1.5+6` e confirmar a deteccao da `v2.1.6+7`.
3. **CI**: confirmar o workflow `CI` verde em `main`.
