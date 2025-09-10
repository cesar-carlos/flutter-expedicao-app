import 'package:flutter/material.dart';

abstract class AppError {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppError({required this.message, this.code, this.stackTrace});
  String get userMessage => message;
}

class NetworkError extends AppError {
  NetworkError({required super.message, super.code, super.stackTrace});

  @override
  String get userMessage =>
      'Falha na conexão. Verifique sua internet e tente novamente.';
}

class DataError extends AppError {
  DataError({required super.message, super.code, super.stackTrace});
}

extension AppErrorUI on BuildContext {
  void showErrorSnackBar(AppError error) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(content: Text(error.userMessage), backgroundColor: Colors.red),
    );
  }
}
