class ReleaseAsset {
  final String name;
  final String downloadUrl;
  final int size;
  final String contentType;

  const ReleaseAsset({required this.name, required this.downloadUrl, required this.size, required this.contentType});

  bool get isApk => name.toLowerCase().endsWith('.apk');

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ReleaseAsset && other.name == name && other.downloadUrl == downloadUrl;
  }

  @override
  int get hashCode => name.hashCode ^ downloadUrl.hashCode;

  @override
  String toString() => 'ReleaseAsset(name: $name, size: $size)';
}
