# Documentação do Projeto

Esta pasta contém documentação sobre a arquitetura e funcionalidades do aplicativo.

## Estrutura de Arquivos

O projeto segue a arquitetura de camadas recomendada pelo Flutter:

```
lib/
  ui/             # Interface do usuário
    screens/      # Telas principais
    widgets/      # Componentes reutilizáveis
  domain/         # Regras de negócio e modelos
    models/       # Entidades e modelos de dados
    usecases/     # Casos de uso e serviços
  data/           # Acesso a dados
    dtos/         # Objetos de transferência de dados
    repositories/ # Implementações de repositórios
    datasources/  # Fontes de dados (API, banco local)
  core/           # Utilitários e componentes centrais
    errors/       # Tratamento de erros
    network/      # Configurações de rede
  di/             # Injeção de dependências
```

## Próximos Passos

1. Adicionar dependências necessárias (get_it, provider/riverpod/bloc)
2. Implementar gerenciamento de estado
3. Adicionar testes unitários e de widgets
4. Criar documentação de uso

## Consulte

- [Arquitetura recomendada](./architecture/architecture.md) - Documento detalhado sobre a arquitetura do projeto
