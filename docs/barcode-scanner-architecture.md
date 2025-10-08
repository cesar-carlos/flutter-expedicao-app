# Arquitetura do Scanner de Código de Barras

## Visão Geral

Este documento descreve a arquitetura implementada para o scanner de código de barras via câmera do dispositivo Android. A implementação segue os princípios de **Clean Architecture** e utiliza o padrão **Repository** para facilitar a manutenção e possíveis trocas de biblioteca no futuro.

## Estrutura de Arquivos

```
lib/
├── domain/                                    # Camada de Domínio
│   ├── repositories/
│   │   └── barcode_scanner_repository.dart   # Interface do repository
│   └── usecases/
│       └── scan_barcode/
│           ├── scan_barcode_params.dart      # Parâmetros do UseCase
│           ├── scan_barcode_success.dart     # Resultado de sucesso
│           ├── scan_barcode_failure.dart     # Resultado de falha
│           └── scan_barcode_usecase.dart     # Lógica do UseCase
│
├── data/                                      # Camada de Dados
│   └── repositories/
│       └── barcode_scanner_repository_impl.dart  # Implementação usando flutter_barcode_scanner
│
└── di/                                        # Dependency Injection
    └── locator.dart                           # Registro de dependências
```

## Camadas da Arquitetura

### 1. Domain (Domínio)

A camada de domínio contém as **regras de negócio** e **abstrações** da aplicação. É independente de frameworks e bibliotecas externas.

#### Repository Interface (`barcode_scanner_repository.dart`)

```dart
abstract class BarcodeScannerRepository {
  /// Abre a câmera para escanear um código de barras
  Future<Result<String>> scanBarcode();
}
```

**Responsabilidades:**

- Define o **contrato** para qualquer implementação de scanner
- Não depende de bibliotecas específicas
- Permite fácil substituição de implementação

#### UseCase (`scan_barcode_usecase.dart`)

```dart
class ScanBarcodeUseCase extends UseCase<ScanBarcodeSuccess, ScanBarcodeParams> {
  final BarcodeScannerRepository _scannerRepository;

  // Lógica de negócio aqui
}
```

**Responsabilidades:**

- Orquestra o fluxo de scan
- Valida parâmetros
- Trata erros e transforma em falhas específicas
- Depende apenas da **interface**, não da implementação

### 2. Data (Dados)

A camada de dados contém as **implementações concretas** dos repositories.

#### Repository Implementation (`barcode_scanner_repository_impl.dart`)

```dart
class BarcodeScannerRepositoryImpl implements BarcodeScannerRepository {
  @override
  Future<Result<String>> scanBarcode() async {
    // Usa flutter_barcode_scanner
    final barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      '#ff6666',
      'Cancelar',
      true,
      ScanMode.BARCODE,
    );

    // Trata resultado e retorna
  }
}
```

**Responsabilidades:**

- Implementa a interface do repository
- Integra com a biblioteca `flutter_barcode_scanner`
- Trata exceções e retorna `Result<String>`

### 3. Dependency Injection (DI)

Registra as dependências no container do GetIt.

```dart
locator.registerLazySingleton<BarcodeScannerRepository>(
  () => BarcodeScannerRepositoryImpl(),
);

locator.registerLazySingleton<ScanBarcodeUseCase>(
  () => ScanBarcodeUseCase(
    scannerRepository: locator<BarcodeScannerRepository>(),
  ),
);
```

## Como Usar

### 1. Obter o UseCase do Locator

```dart
final scanBarcodeUseCase = locator<ScanBarcodeUseCase>();
```

### 2. Executar o Scan

```dart
const params = ScanBarcodeParams();
final result = await scanBarcodeUseCase(params);
```

### 3. Processar Resultado

```dart
result.fold(
  (success) {
    print('Código escaneado: ${success.barcode}');
  },
  (failure) {
    print('Erro: ${failure.userMessage}');
  },
);
```

## Vantagens da Arquitetura

### 1. **Separação de Responsabilidades**

- Cada camada tem uma responsabilidade específica
- O domínio não conhece detalhes de implementação
- Fácil de testar cada componente isoladamente

### 2. **Inversão de Dependência**

- O UseCase depende da **interface**, não da implementação
- A implementação pode ser trocada sem afetar o UseCase
- Facilita mocks em testes

### 3. **Facilidade de Manutenção**

- Mudanças em uma camada não afetam as outras
- Código mais organizado e legível
- Fácil de localizar bugs

## Como Trocar de Biblioteca no Futuro

Se você precisar trocar o `flutter_barcode_scanner` por outra biblioteca (ex: `mobile_scanner`, `qr_code_scanner`), siga estes passos:

### Passo 1: Atualizar o pubspec.yaml

```yaml
dependencies:
  # Remover ou comentar
  # flutter_barcode_scanner: ^2.0.0

  # Adicionar nova biblioteca
  mobile_scanner: ^3.0.0
```

### Passo 2: Criar Nova Implementação

Crie um novo arquivo `barcode_scanner_repository_mobile_impl.dart`:

```dart
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:exp/domain/repositories/barcode_scanner_repository.dart';

class BarcodeScannerRepositoryMobileImpl implements BarcodeScannerRepository {
  @override
  Future<Result<String>> scanBarcode() async {
    // Implementação usando mobile_scanner
    // ...
  }
}
```

### Passo 3: Atualizar o DI

No arquivo `lib/di/locator.dart`, troque a implementação:

```dart
// Antes
locator.registerLazySingleton<BarcodeScannerRepository>(
  () => BarcodeScannerRepositoryImpl(),
);

// Depois
locator.registerLazySingleton<BarcodeScannerRepository>(
  () => BarcodeScannerRepositoryMobileImpl(),
);
```

### Passo 4: Deletar Implementação Antiga (Opcional)

```bash
rm lib/data/repositories/barcode_scanner_repository_impl.dart
```

**Pronto!** Nenhuma outra mudança é necessária. O UseCase, ViewModels e telas continuarão funcionando normalmente.

## Fluxo de Dados

```
┌─────────────┐
│     UI      │
│  (Screen)   │
└─────┬───────┘
      │
      │ 1. Chama UseCase
      ▼
┌─────────────────┐
│    UseCase      │
│ (scan_barcode)  │
└─────┬───────────┘
      │
      │ 2. Chama Repository
      ▼
┌─────────────────────┐
│  Repository         │
│  (Interface)        │
└─────┬───────────────┘
      │
      │ 3. Implementação
      ▼
┌──────────────────────────┐
│  Repository Impl         │
│  (flutter_barcode_       │
│   scanner)               │
└─────┬────────────────────┘
      │
      │ 4. Retorna Result
      ▼
┌─────────────────┐
│    UseCase      │
│ (processa)      │
└─────┬───────────┘
      │
      │ 5. Retorna Success/Failure
      ▼
┌─────────────┐
│     UI      │
│  (atualiza) │
└─────────────┘
```

## Tratamento de Erros

O sistema possui tratamento específico para diferentes tipos de erro:

| Código            | Situação                 | Mensagem                          |
| ----------------- | ------------------------ | --------------------------------- |
| SCAN_CANCELLED    | Usuário cancelou o scan  | Scan cancelado pelo usuário       |
| EMPTY_BARCODE     | Código de barras vazio   | Código de barras vazio            |
| SCANNER_ERROR     | Erro genérico do scanner | Erro ao escanear código de barras |
| PERMISSION_DENIED | Sem permissão de câmera  | Permissão de câmera negada        |

## Testes

Para testar o UseCase, você pode criar um mock do repository:

```dart
class MockBarcodeScannerRepository extends Mock
    implements BarcodeScannerRepository {}

void main() {
  test('should return success when scan is successful', () async {
    // Arrange
    final mockRepo = MockBarcodeScannerRepository();
    when(mockRepo.scanBarcode()).thenAnswer((_) async => Success('123456'));

    final useCase = ScanBarcodeUseCase(scannerRepository: mockRepo);

    // Act
    final result = await useCase(const ScanBarcodeParams());

    // Assert
    expect(result.isSuccess(), true);
    result.fold(
      (success) => expect(success.barcode, '123456'),
      (failure) => fail('Should not fail'),
    );
  });
}
```

## Referências

- [Clean Architecture](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Repository Pattern](https://martinfowler.com/eaaCatalog/repository.html)
- [flutter_barcode_scanner](https://pub.dev/packages/flutter_barcode_scanner)
- [result_dart](https://pub.dev/packages/result_dart)
- [get_it](https://pub.dev/packages/get_it)

## Autores

Desenvolvido seguindo os padrões de Clean Architecture do projeto EXP.

Data: Outubro 2025
