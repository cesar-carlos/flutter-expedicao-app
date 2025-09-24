import 'package:flutter/material.dart';

/// Situações possíveis para itens de separação
enum SeparationItemStatus {
  separado('SE', 'Separado', Colors.green),
  pendente('PE', 'Pendente', Colors.orange),
  parcial('PA', 'Parcial', Colors.blue),
  cancelado('CA', 'Cancelado', Colors.red);

  const SeparationItemStatus(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  /// Determina a situação baseada nas quantidades
  static SeparationItemStatus fromQuantities({required double quantidadeTotal, required double quantidadeSeparacao}) {
    if (quantidadeSeparacao <= 0) {
      return SeparationItemStatus.pendente;
    } else if (quantidadeSeparacao >= quantidadeTotal) {
      return SeparationItemStatus.separado;
    } else {
      return SeparationItemStatus.parcial;
    }
  }

  /// Retorna todas as situações disponíveis para filtro
  static List<SeparationItemStatus> get availableForFilter => [
    SeparationItemStatus.separado,
    SeparationItemStatus.pendente,
    SeparationItemStatus.parcial,
  ];

  /// Retorna todas as descrições para filtro
  static List<String> get descriptions => availableForFilter.map((e) => e.description).toList();

  /// Retorna todas as cores para filtro
  static List<Color> get colors => availableForFilter.map((e) => e.color).toList();

  @override
  String toString() => description;
}
