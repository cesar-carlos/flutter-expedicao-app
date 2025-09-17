import 'package:flutter/material.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';

class SeparationInfoDialog extends StatelessWidget {
  final SeparateConsultationModel separation;

  const SeparationInfoDialog({super.key, required this.separation});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Separação ${separation.codSepararEstoque}'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Entidade', separation.nomeEntidade),
          const SizedBox(height: 8),
          _buildInfoRow('Operação', separation.nomeTipoOperacaoExpedicao),
          const SizedBox(height: 8),
          _buildInfoRow('Situação', separation.situacao.description),
          const SizedBox(height: 8),
          _buildInfoRow('Prioridade', separation.nomePrioridade),
          const SizedBox(height: 8),
          _buildInfoRow('Data', _formatDate(separation.dataEmissao)),
          if (separation.observacao != null && separation.observacao!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow('Observação', separation.observacao!),
          ],
        ],
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Fechar'))],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text('$label:', style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        Expanded(child: Text(value)),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }
}
