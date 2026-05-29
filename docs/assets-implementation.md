# Assets da Aplicação - Implementação Completa

## ✅ **Assets Registrados no Pubspec.yaml**

### **📁 Estrutura de Pastas:**

```
assets/
├── icons/
│   ├── app_icon.png          # Ícone principal do app
│   ├── cart_in_full.json     # Animação Lottie do carrinho
│   └── play_store.png        # Ícone para Play Store
│
└── images/
    ├── background.png        # Imagem de fundo
    ├── data7-Icon.png        # Logo principal Data7
    ├── icons8-globo.gif      # Animação de globo
    ├── log_black_icon.ico    # Ícone preto (ICO)
    ├── log_black_icon.png    # Ícone preto (PNG)
    ├── log_se7e_black.png    # Logo Se7e preto
    ├── log_se7e_white.png    # Logo Se7e branco
    ├── log_white.png         # Logo branco
    ├── log_white32px.png     # Logo branco 32px
    └── produto-sem-foto.jpg  # Placeholder para produtos
```

### **📝 Pubspec.yaml - Configuração:**

```yaml
flutter:
  uses-material-design: true
  generate: true

  assets:
    - .env
    - integration_test/.env

    # Ícones
    - assets/icons/
    - assets/icons/app_icon.png
    - assets/icons/cart_in_full.json
    - assets/icons/play_store.png

    # Imagens
    - assets/images/
    - assets/images/background.png
    - assets/images/data7-Icon.png
    - assets/images/icons8-globo.gif
    - assets/images/log_black_icon.ico
    - assets/images/log_black_icon.png
    - assets/images/log_se7e_black.png
    - assets/images/log_se7e_white.png
    - assets/images/log_white.png
    - assets/images/log_white32px.png
    - assets/images/produto-sem-foto.jpg

    # Sons (usados pelo AudioService)
    - assets/som/
    - assets/som/Alert.wav
    - assets/som/AlertFalha.wav
    - assets/som/BarcodeScan.wav
    - assets/som/Disconected.wav
    - assets/som/Error.wav
    - assets/som/Fail.wav
    - assets/som/Notification.wav
    - assets/som/success.wav
    - assets/som/new-notification.mp3
    - assets/som/new-notification-campainha.mp3
    - assets/som/finishi.mp3
```

> **Arquivos `.env`:** `pubspec.yaml` também registra `.env` e
> `integration_test/.env` como assets (carregados via `flutter_dotenv`).

### **🔊 Áudio (`assets/som/`)**

A pasta `assets/som/` contém 11 arquivos de áudio (`.wav`/`.mp3`)
consumidos pelo `AudioService` (`lib/core/services/audio_service.dart`).
O enum interno mapeia cada som por path relativo `som/*.wav|mp3`, por
exemplo: `som/BarcodeScan.wav`, `som/Notification.wav`,
`som/Error.wav`, `som/finishi.mp3`,
`som/new-notification-campainha.mp3`.

## 🏗️ **Arquivos Criados**

### **1. AppAssets - Constantes Centralizadas**

`lib/core/constants/app_assets.dart`

**Funcionalidades:**

- Constantes type-safe para os assets de imagem/ícone
- Organização por categorias (ícones/imagens)
- Prevenção de erros de digitação

> **Notas de manutenção (estado atual):**
>
> - A lista `allAssets` (que enumerava todos os paths) **foi removida** —
>   não havia chamadores e a fonte canônica de assets é o `pubspec.yaml`.
> - A constante `logBlackIconIco` (`log_black_icon.ico`) **foi removida**
>   das constantes: o `.ico` nunca é usado em runtime do Flutter (é o
>   formato Windows-only do ícone do executável, carregado pelo build em
>   `windows/runner/Runner.rc`). O arquivo `.ico` permanece no
>   `pubspec.yaml`/assets apenas para o build Windows.

**Exemplo de Uso:**

```dart
// Ao invés de strings manuais
Image.asset('assets/images/data7-Icon.png')

// Use as constantes
Image.asset(AppAssets.data7Icon)
```

### **2. ProductImage Widget**

`lib/ui/widgets/product/product_image.dart`

**Funcionalidades:**

- Suporte a imagens locais, de rede e assets
- Fallback automático para imagem padrão
- Loading indicator para imagens de rede
- Customização de tamanho e bordas
- Error handling robusto

**Exemplo de Uso:**

```dart
ProductImage(
  imageUrl: produto.imagemUrl,
  width: 100,
  height: 100,
  borderRadius: 12,
)
```

## 📱 **Implementação nas Telas**

> **Importante:** as telas de Splash e Login **não** usam
> `AppAssets.data7Icon` diretamente. Elas usam os componentes
> `AdaptiveLogo` / `AdaptiveLogoContainer`
> (`lib/ui/widgets/common/adaptive_logo.dart`), que selecionam
> `AppAssets.logSe7eBlack` ou `AppAssets.logSe7eWhite` conforme o tema
> (light/dark) e fazem fallback para um ícone quando o asset falha.

### **🌟 SplashScreen:**

```dart
// Logo adaptativo ao tema (light/dark)
AdaptiveLogo(
  width: 120,
  height: 120,
)
```

### **🔐 LoginScreen:**

```dart
// Container com logo adaptativo
AdaptiveLogoContainer(
  width: 130,
  height: 130,
)
```

### **🏠 Home:**

> Não existe a classe `HomeContent`. A home é composta por `HomeScreen`
> com `AppHeader` / `CustomAppBar`.

## 🎨 **Vantagens da Implementação**

### **✅ Type Safety:**

- Constantes previnem erros de digitação
- IDE oferece autocompletar
- Refatoração segura

### **✅ Organização:**

- Assets centralizados e categorizados
- Fácil manutenção e localização
- Estrutura escalável

### **✅ Performance:**

- Assets pré-carregados no build
- Não há network calls desnecessárias
- Caching automático pelo Flutter

### **✅ Robustez:**

- Error handling em todas as imagens
- Fallbacks para casos de erro
- Loading states para imagens de rede

## 🔧 **Como Usar os Assets**

### **Imagens Simples:**

```dart
Image.asset(AppAssets.data7Icon)
```

### **Com Customização:**

```dart
Image.asset(
  AppAssets.background,
  width: double.infinity,
  height: 200,
  fit: BoxFit.cover,
)
```

### **Para Produtos (com fallback):**

```dart
ProductImage(
  imageUrl: produto?.imagem,
  width: 120,
  height: 120,
  borderRadius: 8,
)
```

### **Em Decorations:**

```dart
Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: AssetImage(AppAssets.background),
      fit: BoxFit.cover,
    ),
  ),
)
```

## 📊 **Assets Disponíveis**

> **Uso real no código (estado atual):** `AppAssets` é referenciado em
> apenas **3 arquivos** — `lib/core/constants/app_assets.dart` (definição),
> `lib/ui/widgets/product/product_image.dart` (usa `produtoSemFoto`) e
> `lib/ui/widgets/common/adaptive_logo.dart` (usa `logSe7eBlack` /
> `logSe7eWhite`). As constantes `background`, `globoGif`, `logWhite`,
> `playStoreIcon` e `cartInFullJson` **não têm uso** no código hoje. Não
> há pacote nem uso de Lottie no projeto atual.

### **🔷 Logos e Identidade:**

- `AppAssets.data7Icon` - Logo principal
- `AppAssets.logSe7eBlack` - Variação preta
- `AppAssets.logSe7eWhite` - Variação branca
- `AppAssets.logWhite32px` - Logo pequeno

### **📱 Ícones de App:**

- `AppAssets.appIcon` - Ícone principal
- `AppAssets.playStoreIcon` - Para store

### **🎭 Elementos Visuais:**

- `AppAssets.background` - Fundo
- `AppAssets.globoGif` - Animação globo
- `AppAssets.produtoSemFoto` - Placeholder

### **📦 Animações:**

- `AppAssets.cartInFullJson` - path de animação do carrinho (constante
  declarada, **sem uso** no código; não há Lottie integrado)

## 🚀 **Próximos Passos**

1. **Lottie Animations**: Implementar animações JSON
2. **SVG Support**: Adicionar flutter_svg para ícones vetoriais
3. **Multiple Resolutions**: Adicionar @2x, @3x para diferentes densidades
4. **Asset Generation**: Automatizar geração das constantes
5. **Asset Optimization**: Comprimir imagens para menor build size

## ✨ **Resultado Final**

✅ **Assets organizados e acessíveis** (imagens, ícones e sons)  
✅ **Type-safe constants** para imagens/ícones  
✅ **Widgets reutilizáveis** (`ProductImage`, `AdaptiveLogo`)  
✅ **Error handling robusto** com fallbacks  
✅ **Identidade visual consistente** (logo adaptativo ao tema)

> **Observação realista:** a infraestrutura de assets está pronta, mas
> nem todas as constantes de `AppAssets` são consumidas. O uso efetivo
> hoje se concentra no logo adaptativo (`logSe7eBlack`/`logSe7eWhite`) e
> no placeholder de produto (`produtoSemFoto`); os sons em `assets/som/`
> são usados pelo `AudioService`. Algumas constantes (`background`,
> `globoGif`, `logWhite`, `playStoreIcon`, `cartInFullJson`) seguem sem
> uso no código.
