import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:exp/domain/models/entity_type_model.dart';

void main() {
  group('EntityType', () {
    test('should have correct values for cliente', () {
      expect(EntityType.cliente.code, 'C');
      expect(EntityType.cliente.description, 'Cliente');
      expect(EntityType.cliente.color, Colors.blue);
    });

    test('should have correct values for fornecedor', () {
      expect(EntityType.fornecedor.code, 'F');
      expect(EntityType.fornecedor.description, 'Fornecedor');
      expect(EntityType.fornecedor.color, Colors.green);
    });

    test('should parse code correctly', () {
      expect(EntityType.fromCode('C'), EntityType.cliente);
      expect(EntityType.fromCode('F'), EntityType.fornecedor);
      expect(EntityType.fromCode('c'), EntityType.cliente); // Case insensitive
      expect(
        EntityType.fromCode('f'),
        EntityType.fornecedor,
      ); // Case insensitive
      expect(EntityType.fromCode('X'), null); // Invalid code
      expect(EntityType.fromCode(''), null); // Empty code
    });

    test('should get all codes', () {
      final codes = EntityType.getAllCodes();
      expect(codes, ['C', 'F']);
    });

    test('should get all descriptions', () {
      final descriptions = EntityType.getAllDescriptions();
      expect(descriptions, ['Cliente', 'Fornecedor']);
    });

    test('should validate types correctly', () {
      expect(EntityType.isValidType('C'), true);
      expect(EntityType.isValidType('F'), true);
      expect(EntityType.isValidType('c'), true); // Case insensitive
      expect(EntityType.isValidType('f'), true); // Case insensitive
      expect(EntityType.isValidType('X'), false);
      expect(EntityType.isValidType(''), false);
    });

    test('should get description by code', () {
      expect(EntityType.getDescription('C'), 'Cliente');
      expect(EntityType.getDescription('F'), 'Fornecedor');
      expect(EntityType.getDescription('X'), 'X'); // Returns code if invalid
    });

    test('should get color by code', () {
      expect(EntityType.getColor('C'), Colors.blue);
      expect(EntityType.getColor('F'), Colors.green);
      expect(
        EntityType.getColor('X'),
        Colors.grey,
      ); // Default color for invalid
    });
  });

  group('EntityTypeExtension', () {
    test('should convert string to EntityType', () {
      expect('C'.asEntityType, EntityType.cliente);
      expect('F'.asEntityType, EntityType.fornecedor);
      expect('X'.asEntityType, null);
    });

    test('should get description from string', () {
      expect('C'.entityTypeDescription, 'Cliente');
      expect('F'.entityTypeDescription, 'Fornecedor');
      expect('X'.entityTypeDescription, 'X');
    });

    test('should get color from string', () {
      expect('C'.entityTypeColor, Colors.blue);
      expect('F'.entityTypeColor, Colors.green);
      expect('X'.entityTypeColor, Colors.grey);
    });
  });

  group('EntityTypeModel', () {
    test('should get description', () {
      expect(EntityTypeModel.getDescription('C'), 'Cliente');
      expect(EntityTypeModel.getDescription('F'), 'Fornecedor');
    });

    test('should validate type', () {
      expect(EntityTypeModel.isValidType('C'), true);
      expect(EntityTypeModel.isValidType('F'), true);
      expect(EntityTypeModel.isValidType('X'), false);
    });

    test('should get all codes', () {
      expect(EntityTypeModel.getAllCodes(), ['C', 'F']);
    });

    test('should get all descriptions', () {
      expect(EntityTypeModel.getAllDescriptions(), ['Cliente', 'Fornecedor']);
    });

    test('should get color', () {
      expect(EntityTypeModel.getColor('C'), Colors.blue);
      expect(EntityTypeModel.getColor('F'), Colors.green);
    });

    test('should get all types', () {
      final types = EntityTypeModel.getAllTypes();
      expect(types, [EntityType.cliente, EntityType.fornecedor]);
    });
  });
}
