import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';

/// Utilitários centralizados para gerenciamento de avatares
class AvatarUtils {
  AvatarUtils._(); // Construtor privado para classe utilitária

  /// Extrai as iniciais do nome do usuário
  static String getInitials(String name) {
    if (name.isEmpty) return 'U';

    final parts = name.trim().split(' ');
    if (parts.isEmpty) return 'U';

    if (parts.length == 1) {
      return parts[0].substring(0, 1).toUpperCase();
    } else {
      return '${parts[0].substring(0, 1)}${parts[parts.length - 1].substring(0, 1)}'
          .toUpperCase();
    }
  }

  /// Decodifica string base64 para Uint8List
  static Uint8List decodeBase64Photo(String base64String) {
    try {
      return base64Decode(base64String);
    } catch (e) {
      throw Exception('Erro ao decodificar imagem base64: $e');
    }
  }

  /// Retorna o ImageProvider apropriado (NetworkImage para URL, MemoryImage para base64)
  static ImageProvider? getImageProvider(String? imageData) {
    if (imageData == null || imageData.isEmpty) {
      return null;
    }

    // Verifica se é uma URL (começa com http ou https)
    if (imageData.startsWith('http://') || imageData.startsWith('https://')) {
      return NetworkImage(imageData);
    }

    // Caso contrário, assume que é base64
    try {
      final Uint8List bytes = decodeBase64Photo(imageData);
      return MemoryImage(bytes);
    } catch (e) {
      // Se falhar ao decodificar, retorna null para mostrar iniciais
      return null;
    }
  }

  /// Converte um arquivo de imagem para string base64
  static Future<String?> convertImageToBase64(dynamic imageFile) async {
    try {
      final Uint8List imageBytes = await imageFile.readAsBytes();
      final String base64String = base64Encode(imageBytes);
      return base64String;
    } catch (e) {
      return null;
    }
  }

  /// Cria um CircleAvatar padronizado com foto ou iniciais
  static Widget buildAvatar({
    required String name,
    String? photoBase64,
    required double radius,
    Color? backgroundColor,
    Color? textColor,
    double? fontSize,
    FontWeight? fontWeight,
  }) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: getImageProvider(photoBase64),
      child: photoBase64 == null || photoBase64.isEmpty
          ? Text(
              getInitials(name),
              style: TextStyle(
                color: textColor,
                fontSize: fontSize ?? radius * 0.6,
                fontWeight: fontWeight ?? FontWeight.bold,
              ),
            )
          : null,
    );
  }
}
