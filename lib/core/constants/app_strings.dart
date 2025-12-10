/// Classe que contém todas as strings/textos utilizados na aplicação.
/// Facilita a manutenção, tradução e garante consistência textual.
class AppStrings {
  // Construtor privado para evitar instanciação
  AppStrings._();

  // === GERAL ===
  static const String appName = 'Data7 Expedição';
  static const String appDescription = 'Sistema de expedição Data7';

  // === NAVEGAÇÃO ===
  static const String back = 'Voltar';
  static const String cancel = 'Cancelar';
  static const String save = 'Salvar';
  static const String edit = 'Editar';
  static const String delete = 'Excluir';
  static const String confirm = 'Confirmar';
  static const String close = 'Fechar';
  static const String ok = 'OK';

  // === LOGIN/AUTENTICAÇÃO ===
  static const String loginTitle = 'Faça login para continuar';
  static const String username = 'Usuário';
  static const String password = 'Senha';
  static const String usernameHint = 'Digite seu usuário';
  static const String passwordHint = 'Digite sua senha';
  static const String loginButton = 'Entrar';
  static const String logout = 'Sair';
  static const String registerText = 'Cadastrar';
  static const String registerTitle = 'Criar Nova Conta';
  static const String registerSubtitle = 'Preencha os dados para criar sua conta';
  static const String name = 'Nome';
  static const String nameHint = 'Digite seu nome completo';
  static const String confirmPassword = 'Confirmar Senha';
  static const String confirmPasswordHint = 'Digite a senha novamente';
  static const String profilePhoto = 'Foto do Perfil';
  static const String addPhoto = 'Adicionar Foto';
  static const String changePhoto = 'Alterar Foto';
  static const String removePhoto = 'Remover Foto';
  static const String registerButton = 'Criar Conta';
  static const String backToLogin = 'Voltar ao Login';

  // === VALIDAÇÕES LOGIN ===
  static const String usernameRequired = 'Por favor, digite seu usuário';
  static const String passwordRequired = 'Por favor, digite sua senha';
  static const String passwordMinLength = 'A senha deve ter pelo menos 4 caracteres';
  static const String nameRequired = 'Por favor, digite seu nome';
  static const String nameMaxLength = 'Nome deve ter no máximo 30 caracteres';
  static const String passwordMaxLength = 'Senha deve ter no máximo 60 caracteres';
  static const String confirmPasswordRequired = 'Por favor, confirme sua senha';
  static const String passwordsDoNotMatch = 'As senhas não coincidem';
  static const String registerSuccess = 'Conta criada com sucesso!';
  static const String registerError = 'Erro ao criar conta';

  // === CONFIGURAÇÕES ===
  static const String configTitle = 'Configurações';
  static const String configSubtitle = 'Configure a URL e porta da API';
  static const String serverConfigTitle = 'Configuração do Servidor';
  static const String scannerConfigTitle = 'Configuração do Scanner';
  static const String scannerModeLabel = 'Modo de Leitura';
  static const String scannerModeFocus = 'Focus/Teclado (campo focado)';
  static const String scannerModeBroadcast = 'Broadcast (intent)';
  static const String broadcastActionLabel = 'Ação do Broadcast';
  static const String broadcastExtraLabel = 'Chave do Extra (código de barras)';
  static const String scannerConfigSaved = 'Preferências do scanner salvas!';
  static const String scannerConfigMenu = 'Configuração do Scanner';
  static const String apiUrl = 'URL da API';
  static const String apiPort = 'Porta';
  static const String apiUrlHint = 'Ex: 192.168.1.100';
  static const String apiPortHint = 'Ex: 8080';
  static const String useHttps = 'Usar HTTPS';
  static const String httpsSubtitle = 'Conexão segura (SSL/TLS)';
  static const String testConnection = 'Testar Conexão';
  static const String previewUrl = 'Preview da URL';
  static const String saveConfig = 'Salvar Configuração';
  static const String lastUpdate = 'Última atualização';
  static const String defaultUrl = 'localhost';
  static const String defaultPort = '3001';

  // === VALIDAÇÕES CONFIGURAÇÃO ===
  static const String urlRequired = 'Por favor, digite a URL da API';
  static const String portRequired = 'Por favor, digite a porta';
  static const String portInvalid = 'Porta deve ser um número entre 1 e 65535';

  // === MENSAGENS DE SUCESSO ===
  static const String configSaved = 'Configuração salva com sucesso!';
  static const String connectionSuccess = 'Conexão bem-sucedida!';

  // === MENSAGENS DE ERRO ===
  static const String connectionError = 'Erro ao conectar com o servidor';
  static const String configError = 'Erro ao salvar configuração';
  static const String loginError = 'Erro ao fazer login';
  static const String genericError = 'Ocorreu um erro inesperado';
  static const String networkError = 'Erro de conexão de rede';
  static const String timeoutError = 'Tempo limite de conexão excedido';
  static const String serverNotConfigured = 'Servidor não configurado! Configure o servidor antes de fazer login.';
  static const String serverNotTested = 'Servidor não testado! Teste a conexão com o servidor antes de fazer login.';

  // === MENSAGENS DE ERRO ESPECÍFICAS ===
  static const String loadConfigError = 'Erro ao carregar configuração';
  static const String resetConfigError = 'Erro ao resetar configuração';
  static const String apiUrlEmptyError = 'URL da API não pode estar vazia';
  static const String portRangeError = 'Porta deve ser um número entre 1 e 65535';
  static const String invalidServerResponse = 'Resposta inválida do servidor';
  static const String connectionFailedStatus = 'Falha na conexão: Status';
  static const String connectionTimeout = 'Timeout de conexão';
  static const String receiveTimeout = 'Timeout de resposta';
  static const String connectionCheckError = 'Erro de conexão - Verifique URL e porta';
  static const String badServerResponse = 'Resposta inválida do servidor';
  static const String unexpectedError = 'Erro inesperado';
  static const String connectionFailurePrefix = 'Erro na conexão';

  // === CONSTANTES DE PROTOCOLO ===
  static const String httpsProtocol = 'https';
  static const String httpProtocol = 'http';
  static const String apiEndpoint = '/expedicao';
  static const String expectedApiMessage = 'Expedição API';

  // === LOADING ===
  static const String loading = 'Carregando...';
  static const String connecting = 'Conectando...';
  static const String saving = 'Salvando...';
  static const String testing = 'Testando...';

  // === SPLASH SCREEN ===
  static const String loadingApp = 'Carregando aplicação...';
  static const String initializing = 'Inicializando...';

  // === BOTÕES E AÇÕES ===
  static const String settings = 'Configurações';
  static const String refresh = 'Atualizar';
  static const String retry = 'Tentar Novamente';
  static const String search = 'Pesquisar';
  static const String filter = 'Filtrar';
  static const String clear = 'Limpar';

  // === STATUS ===
  static const String online = 'Online';
  static const String offline = 'Offline';
  static const String connected = 'Conectado';
  static const String disconnected = 'Desconectado';

  // === PERFIL ===
  static const String profileTitle = 'Meu Perfil';
  static const String profileSubtitle = 'Gerencie suas informações pessoais';
  static const String personalInfo = 'Informações Pessoais';
  static const String changeProfilePhoto = 'Alterar Foto do Perfil';
  static const String changePasswordSection = 'Alterar Senha';
  static const String currentPasswordLabel = 'Senha Atual';
  static const String currentPasswordHint = 'Digite sua senha atual';
  static const String newPasswordLabel = 'Nova Senha';
  static const String newPasswordHint = 'Digite a nova senha';
  static const String confirmNewPasswordLabel = 'Confirmar Nova Senha';
  static const String confirmNewPasswordHint = 'Digite a nova senha novamente';
  static const String saveProfile = 'Salvar Alterações';
  static const String profileSaved = 'Perfil atualizado com sucesso!';
  static const String profileError = 'Erro ao atualizar perfil';
  static const String currentPasswordRequired = 'Senha atual é obrigatória para alterar a senha';
  static const String currentPasswordIncorrect = 'Senha atual incorreta';
  static const String newPasswordRequired = 'Nova senha é obrigatória';
  static const String passwordMinLengthProfile = 'A nova senha deve ter pelo menos 4 caracteres';
  static const String confirmNewPasswordRequired = 'Confirmação da nova senha é obrigatória';
  static const String passwordsDoNotMatchProfile = 'As senhas não coincidem';
  static const String photoProcessingError = 'Erro ao processar a imagem';
  static const String passwordChangedSuccess = 'Senha alterada com sucesso!';
  static const String passwordChangeError = 'Erro ao alterar senha';
  static const String profileAndPasswordSaved = 'Perfil e senha atualizados com sucesso!';

  // === TOOLTIPS ===
  static const String settingsTooltip = 'Abrir configurações';
  static const String backTooltip = 'Voltar';
  static const String refreshTooltip = 'Atualizar dados';
}
