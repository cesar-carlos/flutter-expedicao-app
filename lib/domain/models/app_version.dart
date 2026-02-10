class AppVersion {
  final String version;
  final int buildNumber;
  final DateTime? releaseDate;

  const AppVersion({
    required this.version,
    required this.buildNumber,
    this.releaseDate,
  });

  /// Cria uma [AppVersion] validando o formato da string de versão.
  ///
  /// [versionString] deve estar no formato X.Y.Z onde X, Y e Z são números inteiros não negativos.
  /// [buildNumber] é o número do build (padrão: 0).
  ///
  /// Lança [FormatException] se o formato for inválido.
  factory AppVersion.parse(String versionString, {int buildNumber = 0}) {
    final parts = versionString.split('.');

    if (parts.length != 3) {
      throw FormatException(
        'Invalid version format. Expected X.Y.Z, got $versionString',
      );
    }

    final major = int.tryParse(parts[0]);
    final minor = int.tryParse(parts[1]);
    final patch = int.tryParse(parts[2]);

    if (major == null || minor == null || patch == null) {
      throw FormatException(
        'Version parts must be numbers. Got $versionString',
      );
    }

    if (major < 0 || minor < 0 || patch < 0) {
      throw FormatException(
        'Version parts must be non-negative. Got $versionString',
      );
    }

    return AppVersion(version: versionString, buildNumber: buildNumber);
  }

  /// Cria uma [AppVersion] a partir de uma string de tag do GitHub.
  ///
  /// Suporta formatos como:
  /// - `v1.0.2`
  /// - `v1.0.2+3`
  /// - `1.0.2`
  /// - `1.0.2+5`
  ///
  /// Lança [FormatException] se o formato for inválido.
  factory AppVersion.fromTag(String tag) {
    final cleanTag = tag.replaceFirst(RegExp(r'^v'), '');
    final versionMatch = RegExp(r'(\d+\.\d+\.\d+)').firstMatch(cleanTag);

    if (versionMatch == null) {
      throw FormatException(
        'Invalid tag format. Expected v1.0.2 or 1.0.2, got $tag',
      );
    }

    final version = versionMatch.group(1)!;
    final buildMatch = RegExp(r'\+(\d+)').firstMatch(cleanTag);
    final buildNumber = buildMatch != null
        ? int.tryParse(buildMatch.group(1)!) ?? 0
        : 0;

    return AppVersion.parse(version, buildNumber: buildNumber);
  }

  bool isNewerThan(AppVersion other) {
    final currentParts = _parseVersion(version);
    final otherParts = _parseVersion(other.version);

    for (int i = 0; i < 3; i++) {
      if (currentParts[i] > otherParts[i]) return true;
      if (currentParts[i] < otherParts[i]) return false;
    }

    return buildNumber > other.buildNumber;
  }

  int compareTo(AppVersion other) {
    if (isNewerThan(other)) return 1;
    if (other.isNewerThan(this)) return -1;
    return 0;
  }

  List<int> _parseVersion(String version) {
    final parts = version.split('.');
    return [
      int.tryParse(parts[0]) ?? 0,
      parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0,
      parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
    ];
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppVersion &&
        other.version == version &&
        other.buildNumber == buildNumber;
  }

  @override
  int get hashCode => version.hashCode ^ buildNumber.hashCode;

  @override
  String toString() => '$version+$buildNumber';
}
