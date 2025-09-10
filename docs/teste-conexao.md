# Teste de Conexão com Servidor

## Funcionalidade

O botão "Testar Conexão" na tela de configuração permite verificar se o servidor da API está rodando e respondendo corretamente.

## Como Funciona

1. **URL Testada**: `{protocolo}://{url}:{porta}/expedicao`
2. **Método**: GET
3. **Resposta Esperada**:
   - Status: 200
   - Body: `{"message": "Expedição API"}`

## Exemplo de Teste

Se você configurar:

- URL: `localhost`
- Porta: `3000`
- HTTPS: `false`

A requisição será feita para: `http://localhost:3000/expedicao`

## Tipos de Erro

### Erros de Conexão

- **Timeout de conexão**: Servidor não responde em 10 segundos
- **Timeout de resposta**: Servidor demora mais de 10 segundos para responder
- **Erro de conexão**: URL/porta incorretos ou servidor offline

### Erros de Resposta

- **Resposta inválida**: Status diferente de 200
- **Conteúdo incorreto**: JSON não contém `{"message": "Expedição API"}`

## Para Testar com Seu Servidor

1. Certifique-se de que seu servidor está rodando
2. Configure a rota `/expedicao` para retornar:
   ```json
   {
     "message": "Expedição API"
   }
   ```
3. Na tela de configuração do app:
   - Digite a URL do seu servidor
   - Digite a porta
   - Escolha HTTP ou HTTPS
   - Clique em "Testar Conexão"

## Status de Loading

- O botão "Testar Conexão" mostra loading apenas durante o teste
- O botão "Salvar" permanece habilitado durante o teste
- Os estados são independentes para melhor UX
