import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NavigationErrorScreen extends StatelessWidget {
  const NavigationErrorScreen({super.key, required this.message, this.onReturnHome});

  final String message;
  final VoidCallback? onReturnHome;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Não foi possível abrir a tela')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Theme.of(context).colorScheme.error),
              const SizedBox(height: 16),
              Text(message, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              FilledButton(onPressed: onReturnHome ?? () => context.go('/home'), child: const Text('Voltar ao início')),
            ],
          ),
        ),
      ),
    );
  }
}
