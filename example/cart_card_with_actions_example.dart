import 'package:flutter/material.dart';

/// Exemplo visual de como ficará o card de carrinho com os botões de ação
///
/// Este arquivo demonstra a estrutura visual do card de carrinho
/// com a nova seção de ações na parte inferior.
void main() {
  runApp(const CartCardExampleApp());
}

class CartCardExampleApp extends StatelessWidget {
  const CartCardExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cart Card with Actions Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const CartCardExampleScreen(),
    );
  }
}

class CartCardExampleScreen extends StatelessWidget {
  const CartCardExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exemplo - Card de Carrinho com Ações'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Exemplo 1: Carrinho em status "EM SEPARACAO" - Mostra botão "Separar"
            CartCardExample(
              cartCode: '999',
              cartName: 'CARRINHO 999',
              status: 'EM SEPARACAO',
              statusColor: Colors.blue,
              showSeparateButton: true,
              showFinalizeButton: false,
              showCancelButton: false,
            ),

            SizedBox(height: 16),

            // Exemplo 2: Carrinho em status "SEPARANDO" - Mostra botões "Finalizar" e "Cancelar"
            CartCardExample(
              cartCode: '997',
              cartName: 'CARRINHO 997',
              status: 'SEPARANDO',
              statusColor: Colors.orange,
              showSeparateButton: false,
              showFinalizeButton: true,
              showCancelButton: true,
            ),

            SizedBox(height: 16),

            // Exemplo 3: Carrinho em status "SEPARADO" - Mostra botão "Visualizar"
            CartCardExample(
              cartCode: '995',
              cartName: 'CARRINHO 995',
              status: 'SEPARADO',
              statusColor: Colors.green,
              showSeparateButton: false,
              showFinalizeButton: false,
              showCancelButton: false,
              showViewButton: true,
            ),

            SizedBox(height: 16),

            // Exemplo 4: Carrinho em status "CANCELADO" - Mostra botão "Visualizar" com bordas vermelhas
            CartCardExample(
              cartCode: '993',
              cartName: 'CARRINHO 993',
              status: 'CANCELADO',
              statusColor: Colors.red,
              showSeparateButton: false,
              showFinalizeButton: false,
              showCancelButton: false,
              showViewButton: true,
            ),

            SizedBox(height: 16),

            // Exemplo 5: Carrinho em status "CANCELADA" - Mostra botão "Visualizar" com bordas vermelhas
            CartCardExample(
              cartCode: '991',
              cartName: 'CARRINHO 991',
              status: 'CANCELADA',
              statusColor: Colors.red,
              showSeparateButton: false,
              showFinalizeButton: false,
              showCancelButton: false,
              showViewButton: true,
            ),
          ],
        ),
      ),
    );
  }
}

class CartCardExample extends StatelessWidget {
  final String cartCode;
  final String cartName;
  final String status;
  final Color statusColor;
  final bool showSeparateButton;
  final bool showFinalizeButton;
  final bool showCancelButton;
  final bool showViewButton;

  const CartCardExample({
    super.key,
    required this.cartCode,
    required this.cartName,
    required this.status,
    required this.statusColor,
    required this.showSeparateButton,
    required this.showFinalizeButton,
    required this.showCancelButton,
    this.showViewButton = false,
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
        side: BorderSide(color: statusColor.withValues(alpha: 0.4), width: 2),
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
                                Icon(Icons.play_circle_outline, color: Colors.white, size: 16),
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

            const SizedBox(height: 16),

            // Informações do carrinho (simuladas)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
              ),
              child: Row(
                children: [
                  // Código de barras
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.qr_code_2, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Código de Barras',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            cartCode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Origem
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.source, size: 18, color: statusColor),
                            const SizedBox(width: 6),
                            Text(
                              'Origem',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Separação Estoque #123',
                            style: theme.textTheme.bodySmall?.copyWith(color: statusColor, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Informações de tempo (simuladas)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: colorScheme.secondary, shape: BoxShape.circle),
                    child: Icon(Icons.play_arrow, color: Colors.white, size: 16),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Iniciado por Administrador',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSecondaryContainer,
                          ),
                        ),
                        Text(
                          '16/09/2025 às 14:36:51',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSecondaryContainer.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Seção de ações
            const SizedBox(height: 16),
            _buildActionsSection(context, theme, colorScheme, statusColor),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection(BuildContext context, ThemeData theme, ColorScheme colorScheme, Color statusColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.2), width: 1),
      ),
      child: Row(
        children: [
          // Botão de Separar
          if (showSeparateButton) ...[
            Expanded(
              child: _buildActionButton(
                context: context,
                theme: theme,
                colorScheme: colorScheme,
                icon: Icons.play_arrow,
                label: 'Separar',
                color: colorScheme.primary,
                onTap: () => _showSnackBar(context, 'Separar carrinho #$cartCode'),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Botão de Finalizar
          if (showFinalizeButton) ...[
            Expanded(
              child: _buildActionButton(
                context: context,
                theme: theme,
                colorScheme: colorScheme,
                icon: Icons.check_circle,
                label: 'Finalizar',
                color: Colors.green,
                onTap: () => _showSnackBar(context, 'Finalizar carrinho #$cartCode'),
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Botão de Cancelar
          if (showCancelButton) ...[
            Expanded(
              child: _buildActionButton(
                context: context,
                theme: theme,
                colorScheme: colorScheme,
                icon: Icons.cancel_outlined,
                label: 'Cancelar',
                color: colorScheme.error,
                onTap: () => _showSnackBar(context, 'Cancelar carrinho #$cartCode'),
              ),
            ),
          ],

          // Botão de Visualizar
          if (showViewButton) ...[
            Expanded(
              child: _buildActionButton(
                context: context,
                theme: theme,
                colorScheme: colorScheme,
                icon: Icons.visibility,
                label: 'Visualizar',
                color: colorScheme.tertiary,
                onTap: () => _showSnackBar(context, 'Visualizar carrinho #$cartCode'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required BuildContext context,
    required ThemeData theme,
    required ColorScheme colorScheme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(color: color, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message), backgroundColor: Theme.of(context).colorScheme.primary));
  }
}
