# Configuração de Atualização Automática via GitHub

Este guia explica como configurar o sistema de atualização automática do aplicativo usando releases do GitHub.

## Visão Geral

O sistema de atualização automática permite que o aplicativo:

- Verifique automaticamente se há novas versões disponíveis no GitHub
- Baixe o APK do release mais recente
- Instale automaticamente a atualização

## Configuração das Variáveis de Ambiente

### 1. Editar o arquivo `.env`

Adicione as seguintes variáveis ao arquivo `.env` na raiz do projeto:

```env
# Configuração do GitHub para atualizações automáticas
GITHUB_OWNER=seu-usuario-github
GITHUB_REPO=nome-do-repositorio
GITHUB_TOKEN=seu-token-opcional-para-repositorios-privados
```

### 2. Explicação das Variáveis

- **`GITHUB_OWNER`**: Nome de usuário ou organização do GitHub que possui o repositório
  - Exemplo: `data7-expedicao` ou `minha-organizacao`
- **`GITHUB_REPO`**: Nome do repositório no GitHub
  - Exemplo: `app-expedicao` ou `data7-expedicao-app`
- **`GITHUB_TOKEN`**: Token de autenticação do GitHub (opcional)
  - Necessário apenas para repositórios privados
  - Para repositórios públicos, pode ser omitido ou deixado vazio
  - Para criar um token: GitHub → Settings → Developer settings → Personal access tokens → Generate new token
  - Permissões necessárias: `public_repo` (para repositórios públicos) ou `repo` (para repositórios privados)

### 3. Exemplo de Configuração

```env
# Exemplo para repositório público
GITHUB_OWNER=data7-expedicao
GITHUB_REPO=app-expedicao

# Exemplo para repositório privado
GITHUB_OWNER=data7-expedicao
GITHUB_REPO=app-expedicao-privado
GITHUB_TOKEN=ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Formato de Versão e Tags do GitHub

### Versão Atual do App

A versão atual do app é definida no `pubspec.yaml`:

```yaml
version: 1.0.2+3
```

Onde:

- `1.0.2` = versão semântica (major.minor.patch)
- `+3` = build number

### Formato de Tags no GitHub

As tags do GitHub devem seguir o formato semântico:

**Formato recomendado:**

```
v1.0.2
```

**Formato alternativo (com build number):**

```
v1.0.2+3
```

### Como o Sistema Compara Versões

O sistema extrai a versão da tag usando regex:

- Procura por padrão `(\d+\.\d+\.\d+)` na tag (ex: `1.0.2`)
- Opcionalmente procura por `\+(\d+)` para build number (ex: `+3`)
- Se não encontrar build number na tag, usa `0` como padrão

**Exemplos de tags válidas:**

- `v1.0.2` → versão: `1.0.2`, build: `0`
- `v1.0.2+3` → versão: `1.0.2`, build: `3`
- `1.0.2` → versão: `1.0.2`, build: `0` (sem prefixo `v` também funciona)
- `release-1.0.2` → versão: `1.0.2`, build: `0`

**Exemplos de tags inválidas:**

- `v1.0` → não tem formato semântico completo (falta patch)
- `1.0.2-beta` → não será reconhecida corretamente
- `latest` → não contém versão numérica

### Lógica de Comparação

O sistema compara versões da seguinte forma:

1. **Primeiro compara a versão semântica** (major.minor.patch)

   - Se a versão do release for maior → há atualização disponível
   - Se a versão do release for menor → não há atualização
   - Se a versão for igual → vai para o passo 2

2. **Depois compara o build number**
   - Se o build number do release for maior → há atualização disponível
   - Se o build number do release for menor ou igual → não há atualização

**Exemplos:**

- App atual: `1.0.2+3`
- Release GitHub: `v1.0.3` → **Há atualização** (versão maior)
- Release GitHub: `v1.0.2+5` → **Há atualização** (versão igual, mas build maior)
- Release GitHub: `v1.0.2+2` → **Não há atualização** (versão igual, mas build menor)
- Release GitHub: `v1.0.1` → **Não há atualização** (versão menor)

## Criando um Release no GitHub

### Passo 1: Preparar o APK

1. Gere o APK do aplicativo:

   ```bash
   flutter build apk --release
   ```

2. O APK será gerado em:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

### Passo 2: Criar o Release no GitHub

1. Acesse seu repositório no GitHub
2. Vá em **Releases** → **Create a new release**
3. Preencha os campos:
   - **Tag version**: Use o formato `v1.0.2` (ou `v1.0.2+3` se quiser incluir build number)
   - **Release title**: Título descritivo (ex: "Versão 1.0.2 - Correções de bugs")
   - **Description**: Notas do release (opcional, mas recomendado)
4. **Anexe o arquivo APK**:
   - Clique em "Attach binaries"
   - Selecione o arquivo `app-release.apk`
   - **Importante**: O arquivo deve ter extensão `.apk`
5. Clique em **Publish release**

### Passo 3: Verificar o Release

Após criar o release, verifique:

- ✅ A tag foi criada corretamente
- ✅ O APK está anexado ao release
- ✅ O release está publicado (não como draft)

## Como Funciona o Sistema

### Fluxo de Atualização

1. **Inicialização do App** (modo release):

   - O app verifica automaticamente se há atualizações disponíveis
   - Usa as variáveis `GITHUB_OWNER` e `GITHUB_REPO` do `.env`

2. **Verificação de Versão**:

   - Obtém a versão atual do app via `package_info_plus`
   - Busca o último release no GitHub via API
   - Compara as versões usando lógica semântica

3. **Se houver atualização**:

   - Exibe um diálogo informando sobre a atualização disponível
   - Mostra a versão nova e as notas do release
   - Usuário pode escolher atualizar agora ou depois

4. **Download e Instalação**:
   - Ao confirmar, o app baixa o APK do release
   - Mostra progresso do download
   - Após download, abre o instalador do Android
   - Usuário confirma a instalação no sistema Android

### Comportamento

- **Modo Debug**: Não verifica atualizações (apenas em `kReleaseMode`)
- **Modo Release**: Verifica automaticamente ao iniciar
- **Sem Internet**: Não exibe erro, apenas não verifica
- **Erro na Verificação**: Não bloqueia o uso do app

## Troubleshooting

### Problema: "GITHUB_OWNER ou GITHUB_REPO não configurados"

**Solução**: Verifique se as variáveis estão no arquivo `.env` e se o arquivo está sendo carregado corretamente.

### Problema: "APK não encontrado no release"

**Solução**:

- Verifique se o arquivo APK foi anexado ao release
- Certifique-se de que o arquivo tem extensão `.apk`
- Verifique se o release está publicado (não como draft)

### Problema: "Tag name inválida"

**Solução**:

- Use o formato `v1.0.2` ou `v1.0.2+3`
- Certifique-se de que a tag contém 3 números separados por pontos
- Evite caracteres especiais ou texto adicional na tag

### Problema: Atualização não aparece

**Solução**:

- Verifique se a versão do release é maior que a versão atual do app
- Verifique se o build number do release é maior (se a versão for igual)
- Verifique se o app está em modo release (`flutter run --release`)
- Verifique se as variáveis de ambiente estão corretas

### Problema: Erro ao baixar APK

**Solução**:

- Verifique a conexão com a internet
- Verifique se o repositório é público ou se o token está configurado
- Verifique se o link de download do APK está acessível

## Exemplo Completo

### 1. Configuração do `.env`

```env
GITHUB_OWNER=minha-organizacao
GITHUB_REPO=app-expedicao
GITHUB_TOKEN=ghp_abc123def456ghi789jkl012mno345pqr678
```

### 2. Versão Atual no `pubspec.yaml`

```yaml
version: 1.0.2+3
```

### 3. Criar Release no GitHub

- **Tag**: `v1.0.3`
- **Título**: "Versão 1.0.3 - Novas funcionalidades"
- **Descrição**:
  ```
  - Adicionada funcionalidade X
  - Corrigido bug Y
  - Melhorias de performance
  ```
- **APK**: `app-release.apk` (anexado)

### 4. Resultado

Quando o app (versão `1.0.2+3`) iniciar:

- Verificará o release `v1.0.3` no GitHub
- Comparará: `1.0.3 > 1.0.2` → **Há atualização disponível**
- Exibirá o diálogo de atualização
- Usuário pode baixar e instalar a nova versão

## Notas Importantes

1. **Segurança**:

   - O sistema usa HTTPS para comunicação com GitHub
   - O APK é baixado diretamente do GitHub (fonte confiável)
   - O usuário precisa confirmar a instalação no Android

2. **Permissões Android**:

   - O app precisa da permissão `REQUEST_INSTALL_PACKAGES` (já configurada no `AndroidManifest.xml`)

3. **Versionamento**:

   - Sempre incremente a versão no `pubspec.yaml` antes de criar um novo release
   - Use versionamento semântico (major.minor.patch)
   - Build number deve ser incrementado a cada build

4. **Testes**:
   - Teste em modo release: `flutter run --release`
   - Teste com diferentes versões de releases no GitHub
   - Verifique se o diálogo aparece corretamente

## Referências

- [GitHub Releases API](https://docs.github.com/en/rest/releases/releases)
- [Semantic Versioning](https://semver.org/)
- [Flutter Versioning](https://docs.flutter.dev/deployment/versioning)
