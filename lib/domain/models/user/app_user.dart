import 'package:data7_expedicao/domain/models/user_system_models.dart';
import 'package:data7_expedicao/domain/models/situation/situation_model.dart';

class AppUser {
  final int codLoginApp;
  final Situation ativo;
  final String nome;
  final int? codUsuario;
  final String? fotoUsuario;
  final String? senha;
  final UserSystemModel? userSystemModel;

  AppUser({
    required this.codLoginApp,
    required this.ativo,
    required this.nome,
    this.codUsuario,
    this.fotoUsuario,
    this.senha,
    this.userSystemModel,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    // Bug XXXXXXXXXXX: antes os campos NAO-NULLABLE (codLoginApp, nome)
    // eram lidos como `json['CodLoginApp']` direto, sem cast nem
    // fallback. Em 2 cenarios isso crashava com TypeError:
    //
    // 1. SharedPreferences com sessao corrompida (escrita interrompida,
    //    bug em versao anterior que salvou parcial).
    // 2. Migracao de schema (versao antiga nao tinha CodLoginApp).
    //
    // Crash no `loadUserSession()` impedia o app de iniciar (loop:
    // load → crash → relogin → save → load). Agora usamos fallback
    // defensivo + parse de int que aceita varios tipos.
    final codLoginApp = _parseInt(json['CodLoginApp']) ?? 0;
    final userSystemRaw = json['UserSystem'];

    return AppUser(
      codLoginApp: codLoginApp,
      ativo: Situation.fromCodeWithFallback(json['Ativo']?.toString() ?? 'N'),
      nome: json['Nome']?.toString() ?? '',
      codUsuario: _parseInt(json['CodUsuario']),
      fotoUsuario: json['FotoUsuario']?.toString(),
      senha: json['Senha']?.toString(),
      userSystemModel: userSystemRaw is Map
          ? UserSystemModel.fromJson(Map<String, dynamic>.from(userSystemRaw))
          : null,
    );
  }

  /// Parse defensivo de int que aceita int, num, ou String parsavel.
  /// Retorna null se nao for nada disso (mantendo compatibilidade com
  /// campos opcionais como codUsuario).
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }

  bool get isActive => ativo == Situation.ativo;
  bool get hasPhoto => fotoUsuario != null && fotoUsuario!.isNotEmpty;

  AppUser copyWith({
    int? codLoginApp,
    Situation? ativo,
    String? nome,
    int? codUsuario,
    String? fotoUsuario,
    String? senha,
    UserSystemModel? userSystemModel,
  }) {
    return AppUser(
      codLoginApp: codLoginApp ?? this.codLoginApp,
      ativo: ativo ?? this.ativo,
      nome: nome ?? this.nome,
      codUsuario: codUsuario ?? this.codUsuario,
      fotoUsuario: fotoUsuario ?? this.fotoUsuario,
      senha: senha ?? this.senha,
      userSystemModel: userSystemModel ?? this.userSystemModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CodLoginApp': codLoginApp,
      'Ativo': ativo.code,
      'Nome': nome,
      if (codUsuario != null) 'CodUsuario': codUsuario,
      'FotoUsuario': fotoUsuario,
      if (senha != null) 'Senha': senha,
      'UserSystem': userSystemModel?.toMap(),
    };
  }

  @override
  String toString() {
    return 'AppUser(codLoginApp: $codLoginApp, ativo: $ativo, nome: $nome, codUsuario: $codUsuario, fotoUsuario: $fotoUsuario, senha: ${senha != null ? '[HIDDEN]' : 'null'}, hasSystemData: $userSystemModel)';
  }
}
