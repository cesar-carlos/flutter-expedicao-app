import 'package:flutter/material.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/ui/widgets/common/custom_simple_button.dart';

/// Card para exibir informações de uma separação
class SeparationCard extends StatelessWidget {
  final SeparateConsultationModel separation;
  final VoidCallback? onTap;
  final VoidCallback? onSeparate;

  const SeparationCard({super.key, required this.separation, this.onTap, this.onSeparate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header com código e situação
                Row(
                  children: [
                    // Código da separação
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Código',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${separation.codSepararEstoque}',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Status badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: separation.situacao.color,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        separation.situacao.description,
                        style: theme.textTheme.labelMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Informações principais
                _buildInfoRow(
                  context,
                  icon: Icons.business,
                  label: 'Entidade',
                  value: separation.nomeEntidade,
                  subtitle: separation.tipoEntidade.description,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  context,
                  icon: Icons.category,
                  label: 'Operação',
                  value: separation.nomeTipoOperacaoExpedicao,
                ),

                const SizedBox(height: 16),

                _buildInfoRow(
                  context,
                  icon: Icons.priority_high,
                  label: 'Prioridade',
                  value: separation.nomePrioridade,
                ),

                const SizedBox(height: 16),

                // Data e hora
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        icon: Icons.calendar_today,
                        label: 'Data',
                        value: _formatDate(separation.dataEmissao),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildInfoRow(
                        context,
                        icon: Icons.access_time,
                        label: 'Hora',
                        value: separation.horaEmissao,
                      ),
                    ),
                  ],
                ),

                // Observações (se houver)
                if (separation.observacao != null && separation.observacao!.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildInfoRow(
                    context,
                    icon: Icons.note,
                    label: 'Observação',
                    value: separation.observacao!,
                    maxLines: 2,
                  ),
                ],

                const SizedBox(height: 20),

                // Botão Separar
                _buildSeparateButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    String? subtitle,
    int? maxLines,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                maxLines: maxLines,
                overflow: maxLines != null ? TextOverflow.ellipsis : null,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeparateButton(BuildContext context) {
    return CustomSimpleButtonVariations.primary(
      text: 'Abrir Separação',
      icon: Icons.inventory_2,
      onPressed: () => _onSeparatePressed(context),
    );
  }

  void _onSeparatePressed(BuildContext context) {
    if (onSeparate != null) {
      onSeparate!();
    } else {
      // Fallback: mostrar mensagem de desenvolvimento
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Separação ${separation.codSepararEstoque} - Funcionalidade em desenvolvimento'),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }
}
