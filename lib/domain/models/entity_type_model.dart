enum EntityType {
  cliente('C', 'Cliente'),
  fornecedor('F', 'Fornecedor');

  const EntityType(this.code, this.description);

  final String code;
  final String description;

  static EntityType? fromCode(String code) {
    try {
      return EntityType.values.firstWhere((type) => type.code == code.toUpperCase());
    } catch (e) {
      return null;
    }
  }

  static List<String> getAllCodes() {
    return EntityType.values.map((e) => e.code).toList();
  }

  static List<String> getAllDescriptions() {
    return EntityType.values.map((e) => e.description).toList();
  }

  static bool isValidType(String code) {
    return fromCode(code) != null;
  }

  static String getDescription(String code) {
    return fromCode(code)?.description ?? code;
  }
}

extension EntityTypeExtension on String {
  EntityType? get asEntityType => EntityType.fromCode(this);
  String get entityTypeDescription => EntityType.getDescription(this);
}

class EntityTypeModel {
  EntityTypeModel._();

  static String getDescription(String code) => EntityType.getDescription(code);

  static bool isValidType(String code) => EntityType.isValidType(code);

  static List<String> getAllCodes() => EntityType.getAllCodes();

  static List<String> getAllDescriptions() => EntityType.getAllDescriptions();

  static List<EntityType> getAllTypes() => EntityType.values;
}
