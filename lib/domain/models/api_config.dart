import 'package:hive/hive.dart';

part 'api_config.g.dart';

@HiveType(typeId: 0)
class ApiConfig extends HiveObject {
  @HiveField(0)
  String apiUrl;

  @HiveField(1)
  int apiPort;

  @HiveField(2)
  bool useHttps;

  @HiveField(3)
  DateTime? lastUpdated;

  ApiConfig({
    required this.apiUrl,
    required this.apiPort,
    this.useHttps = false,
    this.lastUpdated,
  });

  String get fullUrl {
    final protocol = useHttps ? 'https' : 'http';
    return '$protocol://$apiUrl:$apiPort';
  }

  static ApiConfig get defaultConfig => ApiConfig(
    apiUrl: 'localhost',
    apiPort: 3001,
    useHttps: false,
    lastUpdated: DateTime.now(),
  );

  ApiConfig copyWith({
    String? apiUrl,
    int? apiPort,
    bool? useHttps,
    DateTime? lastUpdated,
  }) {
    return ApiConfig(
      apiUrl: apiUrl ?? this.apiUrl,
      apiPort: apiPort ?? this.apiPort,
      useHttps: useHttps ?? this.useHttps,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'ApiConfig(url: $apiUrl, port: $apiPort, https: $useHttps, fullUrl: $fullUrl)';
  }
}
