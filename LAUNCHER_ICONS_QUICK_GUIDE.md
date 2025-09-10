# 🚀 Guia Rápido: Gerar Ícones do Launcher

## ⚡ Execução Rápida (Windows)

Clique duas vezes no arquivo:

```
generate_launcher_icons.bat
```

## 💻 Comando Manual

```bash
# 1. Navegue para o projeto
cd "d:\Developer\Data7\Expedicao\Flutter\app\exp"

# 2. Instale dependências (se necessário)
flutter pub get

# 3. Gere os ícones
dart run flutter_launcher_icons
```

## ✅ Verificação

Após executar, verifique se os arquivos foram criados:

- **Android**: `android/app/src/main/res/mipmap-*/launcher_icon.png`
- **iOS**: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Web**: `web/icons/Icon-*.png`
- **Windows**: `windows/runner/resources/app_icon.ico`

## 📱 Teste

Após gerar os ícones:

```bash
flutter clean
flutter run
```

O app deve aparecer com o ícone Data7 personalizado! 🎯

---

**💡 Dica**: Execute este processo apenas uma vez, ou sempre que alterar o arquivo `assets/icons/app_icon.png`
