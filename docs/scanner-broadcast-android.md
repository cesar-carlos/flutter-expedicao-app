# Scanner Broadcast Android

O modo `Broadcast (intent)` recebe leituras emitidas pelo app ou servico do
coletor. No Android 13+, o receiver dinamico e exportado para manter
compatibilidade com emissores externos.

## Configuracao Recomendada

- Prefira `action` e `extraKey` especificos do modelo/servico do coletor quando
  o fabricante permitir.
- Evite manter os defaults `com.scanner.BARCODE` e `data` em producao se o
  equipamento suportar valores proprios.
- Deixe o modo `Focus/Teclado` selecionado quando o coletor envia a leitura como
  teclado fisico.

## Defaults

Os defaults continuam disponiveis por compatibilidade:

- `action`: `com.scanner.BARCODE`
- `extraKey`: `data`

Quando esses valores sao usados, o app mantem o funcionamento atual e registra
um aviso em log/UI porque qualquer app que conheca a action pode emitir um
broadcast compativel.

## Checklist De Seguranca

- Configure `action` e `extraKey` explicitamente quando o coletor permitir.
- Evite defaults em producao, principalmente em aparelhos com apps de terceiros
  instalados.
- Mantenha o receiver exportado no Android 13+ apenas porque coletores externos
  precisam emitir o intent.
- Valide manualmente o scan no aparelho alvo apos qualquer troca de action,
  extraKey ou app de coleta.
- Registre a configuracao homologada do modelo de coletor junto da release.
