class PrinterConfig {
  final String id;
  final String name;
  final String ip;
  final int port;
  final int? leftMarginMm;

  const PrinterConfig({required this.id, required this.name, required this.ip, this.port = 9100, this.leftMarginMm});

  PrinterConfig copyWith({String? id, String? name, String? ip, int? port, int? leftMarginMm}) {
    return PrinterConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      ip: ip ?? this.ip,
      port: port ?? this.port,
      leftMarginMm: leftMarginMm ?? this.leftMarginMm,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'ip': ip, 'port': port, if (leftMarginMm != null) 'leftMarginMm': leftMarginMm};
  }

  factory PrinterConfig.fromJson(Map<String, dynamic> json) {
    final rawPort = json['port'];
    final port = rawPort is int ? rawPort : int.tryParse(rawPort?.toString() ?? '');
    final rawLeftMarginMm = json['leftMarginMm'];
    final leftMarginMm = rawLeftMarginMm is int ? rawLeftMarginMm : int.tryParse(rawLeftMarginMm?.toString() ?? '');

    return PrinterConfig(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      ip: json['ip']?.toString() ?? '',
      port: port ?? 9100,
      leftMarginMm: leftMarginMm,
    );
  }
}
