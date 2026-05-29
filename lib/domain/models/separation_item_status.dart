enum SeparationItemStatus {
  separado('SE', 'Separado'),
  pendente('PE', 'Pendente'),
  parcial('PA', 'Parcial'),
  cancelado('CA', 'Cancelado');

  const SeparationItemStatus(this.code, this.description);

  final String code;
  final String description;

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

  @override
  String toString() => description;
}
