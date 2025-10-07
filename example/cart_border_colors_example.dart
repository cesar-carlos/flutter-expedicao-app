import 'package:flutter/material.dart';

/// Exemplo visual das cores de borda dos cards de carrinho
///
/// Este arquivo demonstra como ficam as bordas coloridas para diferentes
/// status de carrinho: verde para finalizados, vermelho para cancelados.
void main() {
  runApp(const CartBorderColorsExampleApp());
}

class CartBorderColorsExampleApp extends StatelessWidget {
  const CartBorderColorsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Border Colors Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const CartBorderColorsExampleScreen(),
    );
  }
}

class CartBorderColorsExampleScreen extends StatelessWidget {
  const CartBorderColorsExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cores de Borda dos Carrinhos'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status dos Carrinhos e suas Cores de Borda:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Carrinho Separado (Verde)
            CartBorderExample(
              cartCode: '999',
              cartName: 'CARRINHO 999',
              status: 'SEPARADO',
              statusColor: Colors.green,
              description: 'Carrinho separado com sucesso - Borda VERDE',
            ),

            SizedBox(height: 16),

            // Carrinho Conferido (Verde)
            CartBorderExample(
              cartCode: '998',
              cartName: 'CARRINHO 998',
              status: 'CONFERIDO',
              statusColor: Colors.green,
              description: 'Carrinho conferido - Borda VERDE',
            ),

            SizedBox(height: 16),

            // Carrinho Cancelado (Vermelho)
            CartBorderExample(
              cartCode: '997',
              cartName: 'CARRINHO 997',
              status: 'CANCELADO',
              statusColor: Colors.red,
              description: 'Carrinho cancelado - Borda VERMELHA',
            ),

            SizedBox(height: 16),

            // Carrinho Cancelada (Vermelho)
            CartBorderExample(
              cartCode: '996',
              cartName: 'CARRINHO 996',
              status: 'CANCELADA',
              statusColor: Colors.red,
              description: 'Carrinho cancelada - Borda VERMELHA',
            ),

            SizedBox(height: 16),

            // Carrinho Separando (Azul)
            CartBorderExample(
              cartCode: '995',
              cartName: 'CARRINHO 995',
              status: 'SEPARANDO',
              statusColor: Colors.blue,
              description: 'Carrinho em separação - Borda AZUL',
            ),

            SizedBox(height: 16),

            // Carrinho Em Separação (Azul)
            CartBorderExample(
              cartCode: '994',
              cartName: 'CARRINHO 994',
              status: 'EM SEPARACAO',
              statusColor: Colors.blue,
              description: 'Carrinho em separação - Borda AZUL',
            ),
          ],
        ),
      ),
    );
  }
}

class CartBorderExample extends StatelessWidget {
  final String cartCode;
  final String cartName;
  final String status;
  final Color statusColor;
  final String description;

  const CartBorderExample({
    super.key,
    required this.cartCode,
    required this.cartName,
    required this.status,
    required this.statusColor,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      shadowColor: statusColor.withValues(alpha: 0.2),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor, width: 3), // Borda mais espessa para destacar
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [statusColor.withValues(alpha: 0.05), statusColor.withValues(alpha: 0.02)],
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header principal
            Row(
              children: [
                // Ícone do carrinho
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_cart, color: statusColor, size: 24),
                ),
                const SizedBox(width: 12),

                // Informações principais
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Código do carrinho
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '#$cartCode',
                              style: theme.textTheme.labelMedium?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Status visual
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: statusColor,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: statusColor.withValues(alpha: 0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(_getStatusIcon(status), color: Colors.white, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  status,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Nome do carrinho
                      Text(
                        cartName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Descrição da cor da borda
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: statusColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      description,
                      style: theme.textTheme.bodyMedium?.copyWith(color: statusColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'SEPARADO':
      case 'CONFERIDO':
        return Icons.check_circle;
      case 'CANCELADO':
      case 'CANCELADA':
        return Icons.cancel;
      case 'SEPARANDO':
      case 'EM SEPARACAO':
        return Icons.play_circle;
      default:
        return Icons.info;
    }
  }
}
