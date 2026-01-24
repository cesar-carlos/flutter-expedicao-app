import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('en', 'US'),
    Locale('pt'),
    Locale('pt', 'BR'),
  ];

  /// No description provided for @back.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @cancel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @edit.
  ///
  /// In pt_BR, this message translates to:
  /// **'Editar'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In pt_BR, this message translates to:
  /// **'Excluir'**
  String get delete;

  /// No description provided for @confirm.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar'**
  String get confirm;

  /// No description provided for @close.
  ///
  /// In pt_BR, this message translates to:
  /// **'Fechar'**
  String get close;

  /// No description provided for @ok.
  ///
  /// In pt_BR, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @appName.
  ///
  /// In pt_BR, this message translates to:
  /// **'Data7 Expedição'**
  String get appName;

  /// No description provided for @appDescription.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sistema de expedição Data7'**
  String get appDescription;

  /// No description provided for @loginTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Faça login para continuar'**
  String get loginTitle;

  /// No description provided for @username.
  ///
  /// In pt_BR, this message translates to:
  /// **'Usuário'**
  String get username;

  /// No description provided for @password.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @usernameHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite seu usuário'**
  String get usernameHint;

  /// No description provided for @passwordHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite sua senha'**
  String get passwordHint;

  /// No description provided for @loginButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @logout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @registerText.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cadastrar'**
  String get registerText;

  /// No description provided for @registerTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar Nova Conta'**
  String get registerTitle;

  /// No description provided for @registerSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preencha os dados para criar sua conta'**
  String get registerSubtitle;

  /// No description provided for @name.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome'**
  String get name;

  /// No description provided for @nameHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite seu nome completo'**
  String get nameHint;

  /// No description provided for @confirmPassword.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar Senha'**
  String get confirmPassword;

  /// No description provided for @confirmPasswordHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite a senha novamente'**
  String get confirmPasswordHint;

  /// No description provided for @profilePhoto.
  ///
  /// In pt_BR, this message translates to:
  /// **'Foto do Perfil'**
  String get profilePhoto;

  /// No description provided for @addPhoto.
  ///
  /// In pt_BR, this message translates to:
  /// **'Adicionar Foto'**
  String get addPhoto;

  /// No description provided for @changePhoto.
  ///
  /// In pt_BR, this message translates to:
  /// **'Alterar Foto'**
  String get changePhoto;

  /// No description provided for @removePhoto.
  ///
  /// In pt_BR, this message translates to:
  /// **'Remover Foto'**
  String get removePhoto;

  /// No description provided for @registerButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Criar Conta'**
  String get registerButton;

  /// No description provided for @backToLogin.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar ao Login'**
  String get backToLogin;

  /// No description provided for @loginSystem.
  ///
  /// In pt_BR, this message translates to:
  /// **'Login System'**
  String get loginSystem;

  /// No description provided for @configurationNeeded.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configuração Necessária'**
  String get configurationNeeded;

  /// No description provided for @configure.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configurar'**
  String get configure;

  /// No description provided for @usernameRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite seu usuário'**
  String get usernameRequired;

  /// No description provided for @passwordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite sua senha'**
  String get passwordRequired;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'A senha deve ter pelo menos {minLength} caracteres'**
  String passwordMinLength(int minLength);

  /// No description provided for @nameRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite seu nome'**
  String get nameRequired;

  /// No description provided for @nameMaxLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nome deve ter no máximo {maxLength} caracteres'**
  String nameMaxLength(int maxLength);

  /// No description provided for @passwordMaxLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha deve ter no máximo {maxLength} caracteres'**
  String passwordMaxLength(int maxLength);

  /// No description provided for @confirmPasswordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, confirme sua senha'**
  String get confirmPasswordRequired;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt_BR, this message translates to:
  /// **'As senhas não coincidem'**
  String get passwordsDoNotMatch;

  /// No description provided for @emailRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite um email'**
  String get emailRequired;

  /// No description provided for @emailInvalid.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite um email válido'**
  String get emailInvalid;

  /// No description provided for @fieldRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite {fieldName}'**
  String fieldRequired(String fieldName);

  /// No description provided for @fieldMustBeNumber.
  ///
  /// In pt_BR, this message translates to:
  /// **'{fieldName} deve ser um número válido'**
  String fieldMustBeNumber(String fieldName);

  /// No description provided for @fieldMinLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'{fieldName} deve ter pelo menos {minLength} caracteres'**
  String fieldMinLength(String fieldName, int minLength);

  /// No description provided for @fieldMaxLength.
  ///
  /// In pt_BR, this message translates to:
  /// **'{fieldName} deve ter no máximo {maxLength} caracteres'**
  String fieldMaxLength(String fieldName, int maxLength);

  /// No description provided for @codeMustBeNumeric.
  ///
  /// In pt_BR, this message translates to:
  /// **'Código deve ser numérico'**
  String get codeMustBeNumeric;

  /// No description provided for @invalidOrigin.
  ///
  /// In pt_BR, this message translates to:
  /// **'Origem inválida'**
  String get invalidOrigin;

  /// No description provided for @invalidSituation.
  ///
  /// In pt_BR, this message translates to:
  /// **'Situação inválida'**
  String get invalidSituation;

  /// No description provided for @invalidEntityType.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tipo de entidade inválido (deve ser C ou F)'**
  String get invalidEntityType;

  /// No description provided for @configTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configurações'**
  String get configTitle;

  /// No description provided for @configSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configure a URL e porta da API'**
  String get configSubtitle;

  /// No description provided for @serverConfigTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configuração do Servidor'**
  String get serverConfigTitle;

  /// No description provided for @scannerConfigTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configuração do Scanner'**
  String get scannerConfigTitle;

  /// No description provided for @scannerModeLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Modo de Leitura'**
  String get scannerModeLabel;

  /// No description provided for @scannerModeFocus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Focus/Teclado (campo focado)'**
  String get scannerModeFocus;

  /// No description provided for @scannerModeBroadcast.
  ///
  /// In pt_BR, this message translates to:
  /// **'Broadcast (intent)'**
  String get scannerModeBroadcast;

  /// No description provided for @broadcastActionLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ação do Broadcast'**
  String get broadcastActionLabel;

  /// No description provided for @broadcastExtraLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Chave do Extra (código de barras)'**
  String get broadcastExtraLabel;

  /// No description provided for @scannerConfigSaved.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preferências do scanner salvas!'**
  String get scannerConfigSaved;

  /// No description provided for @scannerConfigMenu.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configuração do Scanner'**
  String get scannerConfigMenu;

  /// No description provided for @apiUrl.
  ///
  /// In pt_BR, this message translates to:
  /// **'URL da API'**
  String get apiUrl;

  /// No description provided for @apiPort.
  ///
  /// In pt_BR, this message translates to:
  /// **'Porta'**
  String get apiPort;

  /// No description provided for @apiUrlHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex: 192.168.1.100'**
  String get apiUrlHint;

  /// No description provided for @apiPortHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ex: 8080'**
  String get apiPortHint;

  /// No description provided for @useHttps.
  ///
  /// In pt_BR, this message translates to:
  /// **'Usar HTTPS'**
  String get useHttps;

  /// No description provided for @httpsSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conexão segura (SSL/TLS)'**
  String get httpsSubtitle;

  /// No description provided for @testConnection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Testar Conexão'**
  String get testConnection;

  /// No description provided for @previewUrl.
  ///
  /// In pt_BR, this message translates to:
  /// **'Preview da URL'**
  String get previewUrl;

  /// No description provided for @saveConfig.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar Configuração'**
  String get saveConfig;

  /// No description provided for @lastUpdate.
  ///
  /// In pt_BR, this message translates to:
  /// **'Última atualização'**
  String get lastUpdate;

  /// No description provided for @defaultUrl.
  ///
  /// In pt_BR, this message translates to:
  /// **'localhost'**
  String get defaultUrl;

  /// No description provided for @defaultPort.
  ///
  /// In pt_BR, this message translates to:
  /// **'3001'**
  String get defaultPort;

  /// No description provided for @urlRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite a URL da API'**
  String get urlRequired;

  /// No description provided for @portRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Por favor, digite a porta'**
  String get portRequired;

  /// No description provided for @portInvalid.
  ///
  /// In pt_BR, this message translates to:
  /// **'Porta deve ser um número entre 1 e 65535'**
  String get portInvalid;

  /// No description provided for @registerSuccess.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conta criada com sucesso!'**
  String get registerSuccess;

  /// No description provided for @configSaved.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configuração salva com sucesso!'**
  String get configSaved;

  /// No description provided for @connectionSuccess.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conexão bem-sucedida!'**
  String get connectionSuccess;

  /// No description provided for @profileSaved.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil atualizado com sucesso!'**
  String get profileSaved;

  /// No description provided for @passwordChangedSuccess.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha alterada com sucesso!'**
  String get passwordChangedSuccess;

  /// No description provided for @profileAndPasswordSaved.
  ///
  /// In pt_BR, this message translates to:
  /// **'Perfil e senha atualizados com sucesso!'**
  String get profileAndPasswordSaved;

  /// No description provided for @registerError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao criar conta'**
  String get registerError;

  /// No description provided for @connectionError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao conectar com o servidor'**
  String get connectionError;

  /// No description provided for @configError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao salvar configuração'**
  String get configError;

  /// No description provided for @loginError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao fazer login'**
  String get loginError;

  /// No description provided for @genericError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Ocorreu um erro inesperado'**
  String get genericError;

  /// No description provided for @networkError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro de conexão de rede'**
  String get networkError;

  /// No description provided for @timeoutError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tempo limite de conexão excedido'**
  String get timeoutError;

  /// No description provided for @serverNotConfigured.
  ///
  /// In pt_BR, this message translates to:
  /// **'Servidor não configurado! Configure o servidor antes de fazer login.'**
  String get serverNotConfigured;

  /// No description provided for @serverNotTested.
  ///
  /// In pt_BR, this message translates to:
  /// **'Servidor não testado! Teste a conexão com o servidor antes de fazer login.'**
  String get serverNotTested;

  /// No description provided for @loadConfigError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao carregar configuração'**
  String get loadConfigError;

  /// No description provided for @resetConfigError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao resetar configuração'**
  String get resetConfigError;

  /// No description provided for @apiUrlEmptyError.
  ///
  /// In pt_BR, this message translates to:
  /// **'URL da API não pode estar vazia'**
  String get apiUrlEmptyError;

  /// No description provided for @portRangeError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Porta deve ser um número entre 1 e 65535'**
  String get portRangeError;

  /// No description provided for @invalidServerResponse.
  ///
  /// In pt_BR, this message translates to:
  /// **'Resposta inválida do servidor'**
  String get invalidServerResponse;

  /// No description provided for @connectionFailedStatus.
  ///
  /// In pt_BR, this message translates to:
  /// **'Falha na conexão: Status {statusCode}'**
  String connectionFailedStatus(int statusCode);

  /// No description provided for @connectionTimeout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Timeout de conexão'**
  String get connectionTimeout;

  /// No description provided for @receiveTimeout.
  ///
  /// In pt_BR, this message translates to:
  /// **'Timeout de resposta'**
  String get receiveTimeout;

  /// No description provided for @connectionCheckError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro de conexão - Verifique URL e porta'**
  String get connectionCheckError;

  /// No description provided for @badServerResponse.
  ///
  /// In pt_BR, this message translates to:
  /// **'Resposta inválida do servidor'**
  String get badServerResponse;

  /// No description provided for @unexpectedError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro inesperado'**
  String get unexpectedError;

  /// No description provided for @connectionFailurePrefix.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro na conexão'**
  String get connectionFailurePrefix;

  /// No description provided for @profileError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao atualizar perfil'**
  String get profileError;

  /// No description provided for @currentPasswordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha atual é obrigatória para alterar a senha'**
  String get currentPasswordRequired;

  /// No description provided for @currentPasswordIncorrect.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha atual incorreta'**
  String get currentPasswordIncorrect;

  /// No description provided for @newPasswordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova senha é obrigatória'**
  String get newPasswordRequired;

  /// No description provided for @passwordMinLengthProfile.
  ///
  /// In pt_BR, this message translates to:
  /// **'A nova senha deve ter pelo menos 4 caracteres'**
  String get passwordMinLengthProfile;

  /// No description provided for @confirmNewPasswordRequired.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmação da nova senha é obrigatória'**
  String get confirmNewPasswordRequired;

  /// No description provided for @passwordsDoNotMatchProfile.
  ///
  /// In pt_BR, this message translates to:
  /// **'As senhas não coincidem'**
  String get passwordsDoNotMatchProfile;

  /// No description provided for @photoProcessingError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao processar a imagem'**
  String get photoProcessingError;

  /// No description provided for @passwordChangeError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao alterar senha'**
  String get passwordChangeError;

  /// No description provided for @validationError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Dados inválidos: {errors}'**
  String validationError(String errors);

  /// No description provided for @connectionFailure.
  ///
  /// In pt_BR, this message translates to:
  /// **'Falha na conexão. Verifique sua internet e tente novamente.'**
  String get connectionFailure;

  /// No description provided for @timeoutConnection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Timeout na conexão'**
  String get timeoutConnection;

  /// No description provided for @noInternet.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem conexão com a internet'**
  String get noInternet;

  /// No description provided for @serverError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro do servidor'**
  String get serverError;

  /// No description provided for @unauthenticated.
  ///
  /// In pt_BR, this message translates to:
  /// **'Usuário não autenticado'**
  String get unauthenticated;

  /// No description provided for @unauthorized.
  ///
  /// In pt_BR, this message translates to:
  /// **'Acesso negado'**
  String get unauthorized;

  /// No description provided for @invalidCredentials.
  ///
  /// In pt_BR, this message translates to:
  /// **'Credenciais inválidas'**
  String get invalidCredentials;

  /// No description provided for @dataProcessingError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao processar dados. Tente novamente.'**
  String get dataProcessingError;

  /// No description provided for @entityNotFound.
  ///
  /// In pt_BR, this message translates to:
  /// **'{entity} não encontrado'**
  String entityNotFound(String entity);

  /// No description provided for @parsingError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao processar dados: {details}'**
  String parsingError(String details);

  /// No description provided for @repositoryError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro no repositório: {exception}'**
  String repositoryError(String exception);

  /// No description provided for @invalidState.
  ///
  /// In pt_BR, this message translates to:
  /// **'Estado inválido: {details}'**
  String invalidState(String details);

  /// No description provided for @operationNotAllowed.
  ///
  /// In pt_BR, this message translates to:
  /// **'Operação não permitida: {reason}'**
  String operationNotAllowed(String reason);

  /// No description provided for @unknownError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro inesperado. Tente novamente.'**
  String get unknownError;

  /// No description provided for @unknownErrorDetails.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro inesperado: {exception}'**
  String unknownErrorDetails(String exception);

  /// No description provided for @httpsProtocol.
  ///
  /// In pt_BR, this message translates to:
  /// **'https'**
  String get httpsProtocol;

  /// No description provided for @httpProtocol.
  ///
  /// In pt_BR, this message translates to:
  /// **'http'**
  String get httpProtocol;

  /// No description provided for @apiEndpoint.
  ///
  /// In pt_BR, this message translates to:
  /// **'/expedicao'**
  String get apiEndpoint;

  /// No description provided for @expectedApiMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Expedição API'**
  String get expectedApiMessage;

  /// No description provided for @loading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando...'**
  String get loading;

  /// No description provided for @connecting.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conectando...'**
  String get connecting;

  /// No description provided for @saving.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvando...'**
  String get saving;

  /// No description provided for @testing.
  ///
  /// In pt_BR, this message translates to:
  /// **'Testando...'**
  String get testing;

  /// No description provided for @loadingApp.
  ///
  /// In pt_BR, this message translates to:
  /// **'Carregando aplicação...'**
  String get loadingApp;

  /// No description provided for @initializing.
  ///
  /// In pt_BR, this message translates to:
  /// **'Inicializando...'**
  String get initializing;

  /// No description provided for @settings.
  ///
  /// In pt_BR, this message translates to:
  /// **'Configurações'**
  String get settings;

  /// No description provided for @refresh.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar'**
  String get refresh;

  /// No description provided for @retry.
  ///
  /// In pt_BR, this message translates to:
  /// **'Tentar Novamente'**
  String get retry;

  /// No description provided for @search.
  ///
  /// In pt_BR, this message translates to:
  /// **'Pesquisar'**
  String get search;

  /// No description provided for @filter.
  ///
  /// In pt_BR, this message translates to:
  /// **'Filtrar'**
  String get filter;

  /// No description provided for @clear.
  ///
  /// In pt_BR, this message translates to:
  /// **'Limpar'**
  String get clear;

  /// No description provided for @online.
  ///
  /// In pt_BR, this message translates to:
  /// **'Online'**
  String get online;

  /// No description provided for @offline.
  ///
  /// In pt_BR, this message translates to:
  /// **'Offline'**
  String get offline;

  /// No description provided for @connected.
  ///
  /// In pt_BR, this message translates to:
  /// **'Conectado'**
  String get connected;

  /// No description provided for @disconnected.
  ///
  /// In pt_BR, this message translates to:
  /// **'Desconectado'**
  String get disconnected;

  /// No description provided for @profileTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Meu Perfil'**
  String get profileTitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Gerencie suas informações pessoais'**
  String get profileSubtitle;

  /// No description provided for @personalInfo.
  ///
  /// In pt_BR, this message translates to:
  /// **'Informações Pessoais'**
  String get personalInfo;

  /// No description provided for @changeProfilePhoto.
  ///
  /// In pt_BR, this message translates to:
  /// **'Alterar Foto do Perfil'**
  String get changeProfilePhoto;

  /// No description provided for @changePasswordSection.
  ///
  /// In pt_BR, this message translates to:
  /// **'Alterar Senha'**
  String get changePasswordSection;

  /// No description provided for @currentPasswordLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Senha Atual'**
  String get currentPasswordLabel;

  /// No description provided for @currentPasswordHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite sua senha atual'**
  String get currentPasswordHint;

  /// No description provided for @newPasswordLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Nova Senha'**
  String get newPasswordLabel;

  /// No description provided for @newPasswordHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite a nova senha'**
  String get newPasswordHint;

  /// No description provided for @confirmNewPasswordLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Confirmar Nova Senha'**
  String get confirmNewPasswordLabel;

  /// No description provided for @confirmNewPasswordHint.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite a nova senha novamente'**
  String get confirmNewPasswordHint;

  /// No description provided for @saveProfile.
  ///
  /// In pt_BR, this message translates to:
  /// **'Salvar Alterações'**
  String get saveProfile;

  /// No description provided for @settingsTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Abrir configurações'**
  String get settingsTooltip;

  /// No description provided for @backTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Voltar'**
  String get backTooltip;

  /// No description provided for @refreshTooltip.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar dados'**
  String get refreshTooltip;

  /// No description provided for @lastReading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Última leitura'**
  String get lastReading;

  /// No description provided for @lastReadingColon.
  ///
  /// In pt_BR, this message translates to:
  /// **'Última leitura:'**
  String get lastReadingColon;

  /// No description provided for @clearReading.
  ///
  /// In pt_BR, this message translates to:
  /// **'Limpar Leitura'**
  String get clearReading;

  /// No description provided for @shelfCode.
  ///
  /// In pt_BR, this message translates to:
  /// **'Código da Prateleira'**
  String get shelfCode;

  /// No description provided for @waitProcessing.
  ///
  /// In pt_BR, this message translates to:
  /// **'Aguarde, processando item...'**
  String get waitProcessing;

  /// No description provided for @typeBarcodeManually.
  ///
  /// In pt_BR, this message translates to:
  /// **'Digite o código de barras manualmente ou toque no ícone para usar o scanner'**
  String get typeBarcodeManually;

  /// No description provided for @positionProductScanner.
  ///
  /// In pt_BR, this message translates to:
  /// **'Posicione o produto no scanner ou toque no ícone para usar o teclado'**
  String get positionProductScanner;

  /// No description provided for @scannerDisabled.
  ///
  /// In pt_BR, this message translates to:
  /// **'Scanner desabilitado - carrinho não está em situação de separação'**
  String get scannerDisabled;

  /// No description provided for @cancelCart.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar Carrinho'**
  String get cancelCart;

  /// No description provided for @appUpdateTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualização Disponível'**
  String get appUpdateTitle;

  /// No description provided for @appUpdateMessage.
  ///
  /// In pt_BR, this message translates to:
  /// **'Uma nova versão do app está disponível:'**
  String get appUpdateMessage;

  /// No description provided for @appUpdateVersionLabel.
  ///
  /// In pt_BR, this message translates to:
  /// **'Versão:'**
  String get appUpdateVersionLabel;

  /// No description provided for @appUpdateLaterButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Depois'**
  String get appUpdateLaterButton;

  /// No description provided for @appUpdateNowButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Atualizar Agora'**
  String get appUpdateNowButton;

  /// No description provided for @appUpdateDownloadingTitle.
  ///
  /// In pt_BR, this message translates to:
  /// **'Baixando Atualização'**
  String get appUpdateDownloadingTitle;

  /// No description provided for @appUpdateInstalling.
  ///
  /// In pt_BR, this message translates to:
  /// **'Instalando atualização...'**
  String get appUpdateInstalling;

  /// No description provided for @appUpdateCancelButton.
  ///
  /// In pt_BR, this message translates to:
  /// **'Cancelar'**
  String get appUpdateCancelButton;

  /// No description provided for @appUpdateChecking.
  ///
  /// In pt_BR, this message translates to:
  /// **'Verificando...'**
  String get appUpdateChecking;

  /// No description provided for @appUpdateNoUpdateAvailable.
  ///
  /// In pt_BR, this message translates to:
  /// **'Você está usando a versão mais recente'**
  String get appUpdateNoUpdateAvailable;

  /// No description provided for @appUpdateCheckError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao verificar atualização'**
  String get appUpdateCheckError;

  /// No description provided for @appUpdateNotConfigured.
  ///
  /// In pt_BR, this message translates to:
  /// **'GITHUB_OWNER ou GITHUB_REPO não configurados'**
  String get appUpdateNotConfigured;

  /// No description provided for @appUpdateNetworkError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Sem conexão com a internet'**
  String get appUpdateNetworkError;

  /// No description provided for @appUpdateDownloadError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao baixar atualização'**
  String get appUpdateDownloadError;

  /// No description provided for @appUpdateInstallError.
  ///
  /// In pt_BR, this message translates to:
  /// **'Erro ao instalar atualização'**
  String get appUpdateInstallError;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'en':
      {
        switch (locale.countryCode) {
          case 'US':
            return AppLocalizationsEnUs();
        }
        break;
      }
    case 'pt':
      {
        switch (locale.countryCode) {
          case 'BR':
            return AppLocalizationsPtBr();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
