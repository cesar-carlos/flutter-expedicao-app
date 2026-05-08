# Release v2.1.2+3

## Resumo

Versão **2.1.2** (build **+3**): alinhamento de **versionName** / **versionCode** para publicação e rastreio de release, sobre o mesmo conjunto de funcionalidades da **2.1.1+2** (branch **main**).

## Notas

- Não há alterações de código em relação ao commit já publicado como **v2.1.1+2**; o incremento é de **versão semântica** e de **build** exigido para novos envios à loja (`versionCode` anterior: **2**).

## Conteúdo herdado da 2.1.1+2

- Separação (`NextSeparationUser`, telas e documentação interna).
- Login por QR endurecido, `SystemQrcodeData` + schema **zard**, testes.
- Picking (diálogo de finalização com scroll, `ScanInputProcessor`).
- CI, testes adicionais, `verify_no_utf8_mojibake`, `.editorconfig`.

## Homologação sugerida

Mesma da **2.1.1+2**: separação, QR, picking (diálogo de finalização), instalação/atualização com **versionCode** maior que o build anterior.
