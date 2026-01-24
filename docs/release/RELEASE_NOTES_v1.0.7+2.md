# Release v1.0.7+2

## Novidades
- ✅ Sistema de Auto Update implementado
- ✅ Verificação manual de atualizações no menu lateral
- ✅ Melhorias na UI do AppDrawer com ícone de atualização
- ✅ FileProvider configurado para instalação segura de APKs

## Melhorias
- Refatoração do AppUpdateViewModel seguindo Clean Architecture
- Documentação completa do sistema de auto-update
- Tratamento de erros aprimorado

## Arquitetura
- Clean Architecture aplicada em todas as camadas
- Separação de responsabilidades (SOLID)
- Testabilidade melhorada

## Documentação
- Documentação técnica completa em `docs/auto-update-system.md`

## Como usar
1. O sistema verifica automaticamente atualizações ao iniciar o app (modo release)
2. O usuário pode verificar manualmente clicando na versão no menu lateral
3. Quando uma atualização estiver disponível, um diálogo será exibido
4. O usuário pode baixar e instalar a atualização diretamente do app

## Configuração
Certifique-se de configurar as variáveis de ambiente no arquivo `.env`:
```
GITHUB_OWNER=cesar-carlos
GITHUB_REPO=flutter-expedicao-app
GITHUB_TOKEN=seu-token-opcional
```
