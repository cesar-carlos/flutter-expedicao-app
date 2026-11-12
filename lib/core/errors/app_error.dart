import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/errors/user_facing_message.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';

abstract class AppError {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  AppError({required this.message, this.code, this.stackTrace});
  String get userMessage => UserFacingMessage.fromText(message);
}

class NetworkError extends AppError {
  NetworkError({required super.message, super.code, super.stackTrace});
}

class DataError extends AppError {
  DataError({required super.message, super.code, super.stackTrace});

  @override
  String toString() => message;
}

extension AppErrorUI on BuildContext {
  void showErrorSnackBar(AppError error) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(error.userMessage),
        backgroundColor: AppColors.error,
      ),
    );
  }
}
