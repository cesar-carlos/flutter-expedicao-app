# Release v1.0.9+4

## Melhorias na Impressão Térmica

### Fluxo TCP

- ✅ ThermalPrinterTcpService: uso de `close()` em vez de `destroy()` para encerramento gracioso
- ✅ Delay de 150ms após `flush()` para garantir transmissão completa dos dados ao SO
- ✅ Redução do risco de perda de dados em impressoras ESC/POS via TCP

### Arquitetura (DIP)

- ✅ Criação das interfaces `IEscPosTicketBuilderService`, `IThermalPrinterTcpService`, `IPrinterPreferencesRepository`, `IThermalPrinterRepository`
- ✅ Extração do `GetDefaultPrinterUseCase` e `PrintFailureMessageHelper`
- ✅ Renomeação de ThermalPrinterRepository para IThermalPrinterRepository

## Melhorias

- Desacoplamento da UI da camada de dados (data)
- Código alinhado com princípios SOLID e Clean Architecture
- Testes e mocks atualizados

## Arquitetura

- Clean Architecture mantida
- Dependency Inversion Principle aplicado nas interfaces de impressão
- Separação de responsabilidades reforçada
