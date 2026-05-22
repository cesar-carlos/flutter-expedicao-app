# Scanner Broadcast Android

O modo `Broadcast (intent)` recebe leituras emitidas pelo app ou serviço do coletor.
No Android 13+, o receiver dinâmico é exportado para manter compatibilidade com esses emissores externos.

## Configuração recomendada

- Prefira `action` e `extraKey` específicos do modelo/serviço do coletor quando o fabricante permitir.
- Evite manter os defaults `com.scanner.BARCODE` e `data` em produção se o equipamento suportar valores próprios.
- Deixe o modo `Focus/Teclado` selecionado quando o coletor envia a leitura como teclado físico.

## Defaults

Os defaults continuam disponíveis por compatibilidade:

- `action`: `com.scanner.BARCODE`
- `extraKey`: `data`

Quando esses valores são usados, o app mantém o funcionamento atual e registra um aviso em log/UI porque qualquer app que conheça a action pode emitir um broadcast compatível.
