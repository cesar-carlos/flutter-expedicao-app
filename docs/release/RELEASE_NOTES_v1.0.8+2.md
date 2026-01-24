# Release v1.0.8+2

## Correções
- ✅ Corrigido bug onde clicar na versão no drawer fechava o menu sem mostrar feedback
- ✅ Corrigido erro `!_debugLocked` ao verificar atualizações manualmente
- ✅ Melhorada a exibição de feedback após verificação de atualização

## Melhorias
- Otimização do fluxo de verificação de atualização no AppDrawer
- Melhor tratamento de contexto do Scaffold após fechamento do Drawer
- Código limpo e otimizado seguindo as regras do projeto

## Arquitetura
- Clean Architecture mantida
- SOLID principles aplicados
- Código revisado e conforme as regras do projeto

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
