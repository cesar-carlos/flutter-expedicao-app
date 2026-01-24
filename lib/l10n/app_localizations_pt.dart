// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get ok => 'OK';

  @override
  String get appName => 'Data7 Expedição';

  @override
  String get appDescription => 'Sistema de expedição Data7';

  @override
  String get loginTitle => 'Faça login para continuar';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get usernameHint => 'Digite seu usuário';

  @override
  String get passwordHint => 'Digite sua senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get registerText => 'Cadastrar';

  @override
  String get registerTitle => 'Criar Nova Conta';

  @override
  String get registerSubtitle => 'Preencha os dados para criar sua conta';

  @override
  String get name => 'Nome';

  @override
  String get nameHint => 'Digite seu nome completo';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get confirmPasswordHint => 'Digite a senha novamente';

  @override
  String get profilePhoto => 'Foto do Perfil';

  @override
  String get addPhoto => 'Adicionar Foto';

  @override
  String get changePhoto => 'Alterar Foto';

  @override
  String get removePhoto => 'Remover Foto';

  @override
  String get registerButton => 'Criar Conta';

  @override
  String get backToLogin => 'Voltar ao Login';

  @override
  String get loginSystem => 'Login System';

  @override
  String get configurationNeeded => 'Configuração Necessária';

  @override
  String get configure => 'Configurar';

  @override
  String get usernameRequired => 'Por favor, digite seu usuário';

  @override
  String get passwordRequired => 'Por favor, digite sua senha';

  @override
  String passwordMinLength(int minLength) {
    return 'A senha deve ter pelo menos $minLength caracteres';
  }

  @override
  String get nameRequired => 'Por favor, digite seu nome';

  @override
  String nameMaxLength(int maxLength) {
    return 'Nome deve ter no máximo $maxLength caracteres';
  }

  @override
  String passwordMaxLength(int maxLength) {
    return 'Senha deve ter no máximo $maxLength caracteres';
  }

  @override
  String get confirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get emailRequired => 'Por favor, digite um email';

  @override
  String get emailInvalid => 'Por favor, digite um email válido';

  @override
  String fieldRequired(String fieldName) {
    return 'Por favor, digite $fieldName';
  }

  @override
  String fieldMustBeNumber(String fieldName) {
    return '$fieldName deve ser um número válido';
  }

  @override
  String fieldMinLength(String fieldName, int minLength) {
    return '$fieldName deve ter pelo menos $minLength caracteres';
  }

  @override
  String fieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName deve ter no máximo $maxLength caracteres';
  }

  @override
  String get codeMustBeNumeric => 'Código deve ser numérico';

  @override
  String get invalidOrigin => 'Origem inválida';

  @override
  String get invalidSituation => 'Situação inválida';

  @override
  String get invalidEntityType => 'Tipo de entidade inválido (deve ser C ou F)';

  @override
  String get configTitle => 'Configurações';

  @override
  String get configSubtitle => 'Configure a URL e porta da API';

  @override
  String get serverConfigTitle => 'Configuração do Servidor';

  @override
  String get scannerConfigTitle => 'Configuração do Scanner';

  @override
  String get scannerModeLabel => 'Modo de Leitura';

  @override
  String get scannerModeFocus => 'Focus/Teclado (campo focado)';

  @override
  String get scannerModeBroadcast => 'Broadcast (intent)';

  @override
  String get broadcastActionLabel => 'Ação do Broadcast';

  @override
  String get broadcastExtraLabel => 'Chave do Extra (código de barras)';

  @override
  String get scannerConfigSaved => 'Preferências do scanner salvas!';

  @override
  String get scannerConfigMenu => 'Configuração do Scanner';

  @override
  String get apiUrl => 'URL da API';

  @override
  String get apiPort => 'Porta';

  @override
  String get apiUrlHint => 'Ex: 192.168.1.100';

  @override
  String get apiPortHint => 'Ex: 8080';

  @override
  String get useHttps => 'Usar HTTPS';

  @override
  String get httpsSubtitle => 'Conexão segura (SSL/TLS)';

  @override
  String get testConnection => 'Testar Conexão';

  @override
  String get previewUrl => 'Preview da URL';

  @override
  String get saveConfig => 'Salvar Configuração';

  @override
  String get lastUpdate => 'Última atualização';

  @override
  String get defaultUrl => 'localhost';

  @override
  String get defaultPort => '3001';

  @override
  String get urlRequired => 'Por favor, digite a URL da API';

  @override
  String get portRequired => 'Por favor, digite a porta';

  @override
  String get portInvalid => 'Porta deve ser um número entre 1 e 65535';

  @override
  String get registerSuccess => 'Conta criada com sucesso!';

  @override
  String get configSaved => 'Configuração salva com sucesso!';

  @override
  String get connectionSuccess => 'Conexão bem-sucedida!';

  @override
  String get profileSaved => 'Perfil atualizado com sucesso!';

  @override
  String get passwordChangedSuccess => 'Senha alterada com sucesso!';

  @override
  String get profileAndPasswordSaved =>
      'Perfil e senha atualizados com sucesso!';

  @override
  String get registerError => 'Erro ao criar conta';

  @override
  String get connectionError => 'Erro ao conectar com o servidor';

  @override
  String get configError => 'Erro ao salvar configuração';

  @override
  String get loginError => 'Erro ao fazer login';

  @override
  String get genericError => 'Ocorreu um erro inesperado';

  @override
  String get networkError => 'Erro de conexão de rede';

  @override
  String get timeoutError => 'Tempo limite de conexão excedido';

  @override
  String get serverNotConfigured =>
      'Servidor não configurado! Configure o servidor antes de fazer login.';

  @override
  String get serverNotTested =>
      'Servidor não testado! Teste a conexão com o servidor antes de fazer login.';

  @override
  String get loadConfigError => 'Erro ao carregar configuração';

  @override
  String get resetConfigError => 'Erro ao resetar configuração';

  @override
  String get apiUrlEmptyError => 'URL da API não pode estar vazia';

  @override
  String get portRangeError => 'Porta deve ser um número entre 1 e 65535';

  @override
  String get invalidServerResponse => 'Resposta inválida do servidor';

  @override
  String connectionFailedStatus(int statusCode) {
    return 'Falha na conexão: Status $statusCode';
  }

  @override
  String get connectionTimeout => 'Timeout de conexão';

  @override
  String get receiveTimeout => 'Timeout de resposta';

  @override
  String get connectionCheckError => 'Erro de conexão - Verifique URL e porta';

  @override
  String get badServerResponse => 'Resposta inválida do servidor';

  @override
  String get unexpectedError => 'Erro inesperado';

  @override
  String get connectionFailurePrefix => 'Erro na conexão';

  @override
  String get profileError => 'Erro ao atualizar perfil';

  @override
  String get currentPasswordRequired =>
      'Senha atual é obrigatória para alterar a senha';

  @override
  String get currentPasswordIncorrect => 'Senha atual incorreta';

  @override
  String get newPasswordRequired => 'Nova senha é obrigatória';

  @override
  String get passwordMinLengthProfile =>
      'A nova senha deve ter pelo menos 4 caracteres';

  @override
  String get confirmNewPasswordRequired =>
      'Confirmação da nova senha é obrigatória';

  @override
  String get passwordsDoNotMatchProfile => 'As senhas não coincidem';

  @override
  String get photoProcessingError => 'Erro ao processar a imagem';

  @override
  String get passwordChangeError => 'Erro ao alterar senha';

  @override
  String validationError(String errors) {
    return 'Dados inválidos: $errors';
  }

  @override
  String get connectionFailure =>
      'Falha na conexão. Verifique sua internet e tente novamente.';

  @override
  String get timeoutConnection => 'Timeout na conexão';

  @override
  String get noInternet => 'Sem conexão com a internet';

  @override
  String get serverError => 'Erro do servidor';

  @override
  String get unauthenticated => 'Usuário não autenticado';

  @override
  String get unauthorized => 'Acesso negado';

  @override
  String get invalidCredentials => 'Credenciais inválidas';

  @override
  String get dataProcessingError => 'Erro ao processar dados. Tente novamente.';

  @override
  String entityNotFound(String entity) {
    return '$entity não encontrado';
  }

  @override
  String parsingError(String details) {
    return 'Erro ao processar dados: $details';
  }

  @override
  String repositoryError(String exception) {
    return 'Erro no repositório: $exception';
  }

  @override
  String invalidState(String details) {
    return 'Estado inválido: $details';
  }

  @override
  String operationNotAllowed(String reason) {
    return 'Operação não permitida: $reason';
  }

  @override
  String get unknownError => 'Erro inesperado. Tente novamente.';

  @override
  String unknownErrorDetails(String exception) {
    return 'Erro inesperado: $exception';
  }

  @override
  String get httpsProtocol => 'https';

  @override
  String get httpProtocol => 'http';

  @override
  String get apiEndpoint => '/expedicao';

  @override
  String get expectedApiMessage => 'Expedição API';

  @override
  String get loading => 'Carregando...';

  @override
  String get connecting => 'Conectando...';

  @override
  String get saving => 'Salvando...';

  @override
  String get testing => 'Testando...';

  @override
  String get loadingApp => 'Carregando aplicação...';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get settings => 'Configurações';

  @override
  String get refresh => 'Atualizar';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get search => 'Pesquisar';

  @override
  String get filter => 'Filtrar';

  @override
  String get clear => 'Limpar';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileSubtitle => 'Gerencie suas informações pessoais';

  @override
  String get personalInfo => 'Informações Pessoais';

  @override
  String get changeProfilePhoto => 'Alterar Foto do Perfil';

  @override
  String get changePasswordSection => 'Alterar Senha';

  @override
  String get currentPasswordLabel => 'Senha Atual';

  @override
  String get currentPasswordHint => 'Digite sua senha atual';

  @override
  String get newPasswordLabel => 'Nova Senha';

  @override
  String get newPasswordHint => 'Digite a nova senha';

  @override
  String get confirmNewPasswordLabel => 'Confirmar Nova Senha';

  @override
  String get confirmNewPasswordHint => 'Digite a nova senha novamente';

  @override
  String get saveProfile => 'Salvar Alterações';

  @override
  String get settingsTooltip => 'Abrir configurações';

  @override
  String get backTooltip => 'Voltar';

  @override
  String get refreshTooltip => 'Atualizar dados';

  @override
  String get lastReading => 'Última leitura';

  @override
  String get lastReadingColon => 'Última leitura:';

  @override
  String get clearReading => 'Limpar Leitura';

  @override
  String get shelfCode => 'Código da Prateleira';

  @override
  String get waitProcessing => 'Aguarde, processando item...';

  @override
  String get typeBarcodeManually =>
      'Digite o código de barras manualmente ou toque no ícone para usar o scanner';

  @override
  String get positionProductScanner =>
      'Posicione o produto no scanner ou toque no ícone para usar o teclado';

  @override
  String get scannerDisabled =>
      'Scanner desabilitado - carrinho não está em situação de separação';

  @override
  String get cancelCart => 'Cancelar Carrinho';
}

/// The translations for Portuguese, as used in Brazil (`pt_BR`).
class AppLocalizationsPtBr extends AppLocalizationsPt {
  AppLocalizationsPtBr() : super('pt_BR');

  @override
  String get back => 'Voltar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get save => 'Salvar';

  @override
  String get edit => 'Editar';

  @override
  String get delete => 'Excluir';

  @override
  String get confirm => 'Confirmar';

  @override
  String get close => 'Fechar';

  @override
  String get ok => 'OK';

  @override
  String get appName => 'Data7 Expedição';

  @override
  String get appDescription => 'Sistema de expedição Data7';

  @override
  String get loginTitle => 'Faça login para continuar';

  @override
  String get username => 'Usuário';

  @override
  String get password => 'Senha';

  @override
  String get usernameHint => 'Digite seu usuário';

  @override
  String get passwordHint => 'Digite sua senha';

  @override
  String get loginButton => 'Entrar';

  @override
  String get logout => 'Sair';

  @override
  String get registerText => 'Cadastrar';

  @override
  String get registerTitle => 'Criar Nova Conta';

  @override
  String get registerSubtitle => 'Preencha os dados para criar sua conta';

  @override
  String get name => 'Nome';

  @override
  String get nameHint => 'Digite seu nome completo';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get confirmPasswordHint => 'Digite a senha novamente';

  @override
  String get profilePhoto => 'Foto do Perfil';

  @override
  String get addPhoto => 'Adicionar Foto';

  @override
  String get changePhoto => 'Alterar Foto';

  @override
  String get removePhoto => 'Remover Foto';

  @override
  String get registerButton => 'Criar Conta';

  @override
  String get backToLogin => 'Voltar ao Login';

  @override
  String get loginSystem => 'Login System';

  @override
  String get configurationNeeded => 'Configuração Necessária';

  @override
  String get configure => 'Configurar';

  @override
  String get usernameRequired => 'Por favor, digite seu usuário';

  @override
  String get passwordRequired => 'Por favor, digite sua senha';

  @override
  String passwordMinLength(int minLength) {
    return 'A senha deve ter pelo menos $minLength caracteres';
  }

  @override
  String get nameRequired => 'Por favor, digite seu nome';

  @override
  String nameMaxLength(int maxLength) {
    return 'Nome deve ter no máximo $maxLength caracteres';
  }

  @override
  String passwordMaxLength(int maxLength) {
    return 'Senha deve ter no máximo $maxLength caracteres';
  }

  @override
  String get confirmPasswordRequired => 'Por favor, confirme sua senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';

  @override
  String get emailRequired => 'Por favor, digite um email';

  @override
  String get emailInvalid => 'Por favor, digite um email válido';

  @override
  String fieldRequired(String fieldName) {
    return 'Por favor, digite $fieldName';
  }

  @override
  String fieldMustBeNumber(String fieldName) {
    return '$fieldName deve ser um número válido';
  }

  @override
  String fieldMinLength(String fieldName, int minLength) {
    return '$fieldName deve ter pelo menos $minLength caracteres';
  }

  @override
  String fieldMaxLength(String fieldName, int maxLength) {
    return '$fieldName deve ter no máximo $maxLength caracteres';
  }

  @override
  String get codeMustBeNumeric => 'Código deve ser numérico';

  @override
  String get invalidOrigin => 'Origem inválida';

  @override
  String get invalidSituation => 'Situação inválida';

  @override
  String get invalidEntityType => 'Tipo de entidade inválido (deve ser C ou F)';

  @override
  String get configTitle => 'Configurações';

  @override
  String get configSubtitle => 'Configure a URL e porta da API';

  @override
  String get serverConfigTitle => 'Configuração do Servidor';

  @override
  String get scannerConfigTitle => 'Configuração do Scanner';

  @override
  String get scannerModeLabel => 'Modo de Leitura';

  @override
  String get scannerModeFocus => 'Focus/Teclado (campo focado)';

  @override
  String get scannerModeBroadcast => 'Broadcast (intent)';

  @override
  String get broadcastActionLabel => 'Ação do Broadcast';

  @override
  String get broadcastExtraLabel => 'Chave do Extra (código de barras)';

  @override
  String get scannerConfigSaved => 'Preferências do scanner salvas!';

  @override
  String get scannerConfigMenu => 'Configuração do Scanner';

  @override
  String get apiUrl => 'URL da API';

  @override
  String get apiPort => 'Porta';

  @override
  String get apiUrlHint => 'Ex: 192.168.1.100';

  @override
  String get apiPortHint => 'Ex: 8080';

  @override
  String get useHttps => 'Usar HTTPS';

  @override
  String get httpsSubtitle => 'Conexão segura (SSL/TLS)';

  @override
  String get testConnection => 'Testar Conexão';

  @override
  String get previewUrl => 'Preview da URL';

  @override
  String get saveConfig => 'Salvar Configuração';

  @override
  String get lastUpdate => 'Última atualização';

  @override
  String get defaultUrl => 'localhost';

  @override
  String get defaultPort => '3001';

  @override
  String get urlRequired => 'Por favor, digite a URL da API';

  @override
  String get portRequired => 'Por favor, digite a porta';

  @override
  String get portInvalid => 'Porta deve ser um número entre 1 e 65535';

  @override
  String get registerSuccess => 'Conta criada com sucesso!';

  @override
  String get configSaved => 'Configuração salva com sucesso!';

  @override
  String get connectionSuccess => 'Conexão bem-sucedida!';

  @override
  String get profileSaved => 'Perfil atualizado com sucesso!';

  @override
  String get passwordChangedSuccess => 'Senha alterada com sucesso!';

  @override
  String get profileAndPasswordSaved =>
      'Perfil e senha atualizados com sucesso!';

  @override
  String get registerError => 'Erro ao criar conta';

  @override
  String get connectionError => 'Erro ao conectar com o servidor';

  @override
  String get configError => 'Erro ao salvar configuração';

  @override
  String get loginError => 'Erro ao fazer login';

  @override
  String get genericError => 'Ocorreu um erro inesperado';

  @override
  String get networkError => 'Erro de conexão de rede';

  @override
  String get timeoutError => 'Tempo limite de conexão excedido';

  @override
  String get serverNotConfigured =>
      'Servidor não configurado! Configure o servidor antes de fazer login.';

  @override
  String get serverNotTested =>
      'Servidor não testado! Teste a conexão com o servidor antes de fazer login.';

  @override
  String get loadConfigError => 'Erro ao carregar configuração';

  @override
  String get resetConfigError => 'Erro ao resetar configuração';

  @override
  String get apiUrlEmptyError => 'URL da API não pode estar vazia';

  @override
  String get portRangeError => 'Porta deve ser um número entre 1 e 65535';

  @override
  String get invalidServerResponse => 'Resposta inválida do servidor';

  @override
  String connectionFailedStatus(int statusCode) {
    return 'Falha na conexão: Status $statusCode';
  }

  @override
  String get connectionTimeout => 'Timeout de conexão';

  @override
  String get receiveTimeout => 'Timeout de resposta';

  @override
  String get connectionCheckError => 'Erro de conexão - Verifique URL e porta';

  @override
  String get badServerResponse => 'Resposta inválida do servidor';

  @override
  String get unexpectedError => 'Erro inesperado';

  @override
  String get connectionFailurePrefix => 'Erro na conexão';

  @override
  String get profileError => 'Erro ao atualizar perfil';

  @override
  String get currentPasswordRequired =>
      'Senha atual é obrigatória para alterar a senha';

  @override
  String get currentPasswordIncorrect => 'Senha atual incorreta';

  @override
  String get newPasswordRequired => 'Nova senha é obrigatória';

  @override
  String get passwordMinLengthProfile =>
      'A nova senha deve ter pelo menos 4 caracteres';

  @override
  String get confirmNewPasswordRequired =>
      'Confirmação da nova senha é obrigatória';

  @override
  String get passwordsDoNotMatchProfile => 'As senhas não coincidem';

  @override
  String get photoProcessingError => 'Erro ao processar a imagem';

  @override
  String get passwordChangeError => 'Erro ao alterar senha';

  @override
  String validationError(String errors) {
    return 'Dados inválidos: $errors';
  }

  @override
  String get connectionFailure =>
      'Falha na conexão. Verifique sua internet e tente novamente.';

  @override
  String get timeoutConnection => 'Timeout na conexão';

  @override
  String get noInternet => 'Sem conexão com a internet';

  @override
  String get serverError => 'Erro do servidor';

  @override
  String get unauthenticated => 'Usuário não autenticado';

  @override
  String get unauthorized => 'Acesso negado';

  @override
  String get invalidCredentials => 'Credenciais inválidas';

  @override
  String get dataProcessingError => 'Erro ao processar dados. Tente novamente.';

  @override
  String entityNotFound(String entity) {
    return '$entity não encontrado';
  }

  @override
  String parsingError(String details) {
    return 'Erro ao processar dados: $details';
  }

  @override
  String repositoryError(String exception) {
    return 'Erro no repositório: $exception';
  }

  @override
  String invalidState(String details) {
    return 'Estado inválido: $details';
  }

  @override
  String operationNotAllowed(String reason) {
    return 'Operação não permitida: $reason';
  }

  @override
  String get unknownError => 'Erro inesperado. Tente novamente.';

  @override
  String unknownErrorDetails(String exception) {
    return 'Erro inesperado: $exception';
  }

  @override
  String get httpsProtocol => 'https';

  @override
  String get httpProtocol => 'http';

  @override
  String get apiEndpoint => '/expedicao';

  @override
  String get expectedApiMessage => 'Expedição API';

  @override
  String get loading => 'Carregando...';

  @override
  String get connecting => 'Conectando...';

  @override
  String get saving => 'Salvando...';

  @override
  String get testing => 'Testando...';

  @override
  String get loadingApp => 'Carregando aplicação...';

  @override
  String get initializing => 'Inicializando...';

  @override
  String get settings => 'Configurações';

  @override
  String get refresh => 'Atualizar';

  @override
  String get retry => 'Tentar Novamente';

  @override
  String get search => 'Pesquisar';

  @override
  String get filter => 'Filtrar';

  @override
  String get clear => 'Limpar';

  @override
  String get online => 'Online';

  @override
  String get offline => 'Offline';

  @override
  String get connected => 'Conectado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get profileTitle => 'Meu Perfil';

  @override
  String get profileSubtitle => 'Gerencie suas informações pessoais';

  @override
  String get personalInfo => 'Informações Pessoais';

  @override
  String get changeProfilePhoto => 'Alterar Foto do Perfil';

  @override
  String get changePasswordSection => 'Alterar Senha';

  @override
  String get currentPasswordLabel => 'Senha Atual';

  @override
  String get currentPasswordHint => 'Digite sua senha atual';

  @override
  String get newPasswordLabel => 'Nova Senha';

  @override
  String get newPasswordHint => 'Digite a nova senha';

  @override
  String get confirmNewPasswordLabel => 'Confirmar Nova Senha';

  @override
  String get confirmNewPasswordHint => 'Digite a nova senha novamente';

  @override
  String get saveProfile => 'Salvar Alterações';

  @override
  String get settingsTooltip => 'Abrir configurações';

  @override
  String get backTooltip => 'Voltar';

  @override
  String get refreshTooltip => 'Atualizar dados';

  @override
  String get lastReading => 'Última leitura';

  @override
  String get lastReadingColon => 'Última leitura:';

  @override
  String get clearReading => 'Limpar Leitura';

  @override
  String get shelfCode => 'Código da Prateleira';

  @override
  String get waitProcessing => 'Aguarde, processando item...';

  @override
  String get typeBarcodeManually =>
      'Digite o código de barras manualmente ou toque no ícone para usar o scanner';

  @override
  String get positionProductScanner =>
      'Posicione o produto no scanner ou toque no ícone para usar o teclado';

  @override
  String get scannerDisabled =>
      'Scanner desabilitado - carrinho não está em situação de separação';

  @override
  String get cancelCart => 'Cancelar Carrinho';
}
