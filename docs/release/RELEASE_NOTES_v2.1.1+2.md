# Release v2.1.1+2

## Resumo

Versão **2.1.1** (build **+2**) com foco em **confiabilidade da separação** (próximo caso de uso e telas), **login por QR** mais seguro e testável, **picking** (fluxo de scan e diálogo de finalização) e **qualidade** (CI, testes e verificação de encoding).

## Separação

- **`NextSeparationUser`**: ajustes no use case e novos cenários de falha; ViewModels e telas de separação alinhados ao fluxo.
- **Documentação interna** (`docs/separacao`, `docs/proxima_separacao`): consolidação e redução de redundância nos guias de separação.

## Login por QR

- **`RegisterViaQrcode`**, **`AuthViewModel`** e **`QrcodeLoginScreen`**: fluxo endurecido e mais previsível.
- **`SystemQrcodeData`** com validação via **zard** (`system_qrcode_data_schema`) e testes dedicados.

## Picking

- **`PickingFlowController`**: conteúdo do diálogo de confirmação de finalização com **scroll**, evitando overflow em telas baixas ou layouts apertados.
- **`ScanInputProcessor`**: ajustes e testes associados.

## Qualidade e tooling

- **CI**: workflow em `.github/workflows/ci.yml`.
- **Testes**: cobertura ampliada (use cases, ViewModels, tela de QR, `scan_input_processor`, etc.).
- **`tool/verify_no_utf8_mojibake.dart`**: verificação de encoding no repositório.
- **`.editorconfig`** e pequenos ajustes em **VS Code** / **`AudioService`**.

## Homologação sugerida

1. **Separação**: fluxo de lista → próximo item → erros esperados do servidor; regressão visual nas telas tocadas.
2. **Login QR**: leitura válida/ inválida; regressão de navegação após auth.
3. **Picking**: finalizar carrinho com teclado virtual ou janela baixa; confirmar que o diálogo rola e os botões permanecem acessíveis.
4. **Instalação**: após publicar o APK com **versionCode** maior que o da 2.1.0+1, validar atualização em aparelho de teste.
