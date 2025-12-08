class AppVersion {
  final String version;
  final int buildNumber;
  final DateTime? releaseDate;

  const AppVersion({required this.version, required this.buildNumber, this.releaseDate});

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
    return other is AppVersion && other.version == version && other.buildNumber == buildNumber;
  }

  @override
  int get hashCode => version.hashCode ^ buildNumber.hashCode;

  @override
  String toString() => '$version+$buildNumber';
}
