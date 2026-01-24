import 'package:flutter/material.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

enum SeparationItemStatus {
  separado('SE', 'Separado', AppColors.success),
  pendente('PE', 'Pendente', AppColors.warning),
  parcial('PA', 'Parcial', AppColors.info),
  cancelado('CA', 'Cancelado', AppColors.error);

  const SeparationItemStatus(this.code, this.description, this.color);

  final String code;
  final String description;
  final Color color;

  static SeparationItemStatus fromQuantities({required double quantidadeTotal, required double quantidadeSeparacao}) {
    if (quantidadeSeparacao <= 0) {
      return SeparationItemStatus.pendente;
    } else if (quantidadeSeparacao >= quantidadeTotal) {
      return SeparationItemStatus.separado;
    } else {
      return SeparationItemStatus.parcial;
    }
  }

  static List<SeparationItemStatus> get availableForFilter => [
    SeparationItemStatus.separado,
    SeparationItemStatus.pendente,
    SeparationItemStatus.parcial,
  ];

  static List<String> get descriptions => availableForFilter.map((e) => e.description).toList();

  static List<Color> get colors => availableForFilter.map((e) => e.color).toList();

  @override
  String toString() => description;
}
