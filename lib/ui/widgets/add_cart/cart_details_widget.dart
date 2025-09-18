import 'package:flutter/material.dart';

import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/core/utils/app_helper.dart';

class CartDetailsWidget extends StatelessWidget {
  final ExpeditionCartConsultationModel cart;

  const CartDetailsWidget({super.key, required this.cart});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isReleased = cart.situacao == ExpeditionCartSituation.liberado;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: isReleased ? 3 : 1,
      shadowColor: isReleased ? Colors.green.withOpacity(0.3) : null,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isReleased ? Colors.green.withOpacity(0.6) : colorScheme.error.withOpacity(0.6),
          width: isReleased ? 3 : 2,
        ),
      ),
      child: Container(
        decoration: isReleased
            ? BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.green.withOpacity(0.08), Colors.green.withOpacity(0.03)],
                ),
              )
            : null,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header com ícone e status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isReleased ? Colors.green : colorScheme.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.shopping_cart, color: Colors.white, size: 24),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Carrinho Encontrado',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),

                      const SizedBox(height: 4),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isReleased ? Colors.green : colorScheme.error,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cart.situacaoDescription.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Informações do carrinho
            _buildInfoSection(context, 'Informações Básicas', [
              _buildInfoRow(context, 'Código', '${cart.codCarrinho}', Icons.tag),
              _buildInfoRow(context, 'Descrição', cart.descricaoCarrinho, Icons.description),
              _buildInfoRow(context, 'Código de Barras', cart.codigoBarras, Icons.qr_code),
            ]),

            const SizedBox(height: 12),

            // Status e origem
            _buildInfoSection(context, 'Status e Origem', [
              _buildInfoRow(context, 'Situação', cart.situacaoDescription, Icons.info),
              _buildInfoRow(context, 'Ativo', cart.ativoDescription, Icons.check_circle),
              _buildInfoRow(context, 'Origem', cart.origemDescription, Icons.source),
              if (cart.codOrigem != null) _buildInfoRow(context, 'Cód. Origem', '${cart.codOrigem}', Icons.numbers),
            ]),

            // Informações de percurso (se disponível)
            if (cart.codCarrinhoPercurso != null || cart.descricaoPercursoEstagio != null) ...[
              const SizedBox(height: 12),
              _buildInfoSection(context, 'Percurso', [
                if (cart.codCarrinhoPercurso != null)
                  _buildInfoRow(context, 'Cód. Percurso', '${cart.codCarrinhoPercurso}', Icons.route),
                if (cart.codPercursoEstagio != null)
                  _buildInfoRow(context, 'Estágio', '${cart.codPercursoEstagio}', Icons.stairs),
                if (cart.descricaoPercursoEstagio != null)
                  _buildInfoRow(context, 'Desc. Estágio', cart.descricaoPercursoEstagio!, Icons.description),
              ]),
            ],

            // Informações de usuário (se disponível)
            if (cart.nomeUsuarioInicio != null || cart.nomeSetorEstoque != null) ...[
              const SizedBox(height: 12),
              _buildInfoSection(context, 'Informações Adicionais', [
                if (cart.nomeUsuarioInicio != null)
                  _buildInfoRow(context, 'Usuário Início', cart.nomeUsuarioInicio!, Icons.person),
                if (cart.dataInicio != null)
                  _buildInfoRow(context, 'Data Início', AppHelper.formatarData(cart.dataInicio!), Icons.calendar_today),
                if (cart.horaInicio != null) _buildInfoRow(context, 'Hora Início', cart.horaInicio!, Icons.access_time),
                if (cart.nomeSetorEstoque != null)
                  _buildInfoRow(context, 'Setor Estoque', cart.nomeSetorEstoque!, Icons.warehouse),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context, String title, List<Widget> children) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.primary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outline.withOpacity(0.2)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value, IconData icon) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: colorScheme.primary.withOpacity(0.7)),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(value, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface)),
          ),
        ],
      ),
    );
  }
}
