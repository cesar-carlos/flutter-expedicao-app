class PrinterConfig {
  final String id;
  final String name;
  final String ip;
  final int port;

  const PrinterConfig({
    required this.id,
    required this.name,
    required this.ip,
    this.port = 9100,
  });

  PrinterConfig copyWith({String? id, String? name, String? ip, int? port}) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'ip': ip, 'port': port};
  }

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final rawPort = json['port'];
    final port = rawPort is int
        ? rawPort
        : int.tryParse(rawPort?.toString() ?? '');

    return PrinterConfig(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      port: port ?? 9100,
    );
  }
}
