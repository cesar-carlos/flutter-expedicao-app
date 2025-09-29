import 'package:flutter/material.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_situation_model.dart';
import 'package:exp/domain/models/expedition_origem_model.dart';
import 'package:exp/domain/models/situation_model.dart';
import 'package:exp/ui/widgets/separate_items/cart_item_card.dart';

/// Exemplo para testar o botão "Separar" em diferentes situações
void main() {
  runApp(const TestSeparateButtonApp());
}

class TestSeparateButtonApp extends StatelessWidget {
  const TestSeparateButtonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teste Botão Separar',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue), useMaterial3: true),
      home: const TestSeparateButtonScreen(),
    );
  }
}

class TestSeparateButtonScreen extends StatelessWidget {
  const TestSeparateButtonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teste - Botão Separar'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Testando o botão "Abrir Separação" em diferentes situações:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),

            // Exemplo 1: Em Separação - DEVE mostrar botão Abrir Separação
            Text('1. Situação: EM SEPARACAO (deve mostrar botão Abrir Separação)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.emSeparacao),

            SizedBox(height: 16),

            // Exemplo 2: Liberado - DEVE mostrar botão Abrir Separação
            Text('2. Situação: LIBERADO (deve mostrar botão Abrir Separação)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.liberado),

            SizedBox(height: 16),

            // Exemplo 3: Separado - DEVE mostrar botão Abrir Separação (nova funcionalidade)
            Text('3. Situação: SEPARADO (deve mostrar botão Abrir Separação)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.separado),

            SizedBox(height: 16),

            // Exemplo 4: Conferido - DEVE mostrar botão Abrir Separação (nova funcionalidade)
            Text('4. Situação: CONFERIDO (deve mostrar botão Abrir Separação)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.conferido),

            SizedBox(height: 16),

            // Exemplo 5: Separando - DEVE mostrar botão Abrir Separação + Finalizar/Cancelar
            Text('5. Situação: SEPARANDO (deve mostrar botão Abrir Separação + Finalizar/Cancelar)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.separando),

            SizedBox(height: 16),

            // Exemplo 6: Cancelado - NÃO deve mostrar botão Abrir Separação (mostra Visualizar)
            Text('6. Situação: CANCELADO (não deve mostrar botão Abrir Separação)'),
            SizedBox(height: 8),
            TestCartCard(situation: ExpeditionCartSituation.cancelado),
          ],
        ),
      ),
    );
  }
}

class TestCartCard extends StatelessWidget {
  final ExpeditionCartSituation situation;

  const TestCartCard({super.key, required this.situation});

  @override
  Widget build(BuildContext context) {
    // Criar um cart de teste com a situação especificada
    final testCart = ExpeditionCartRouteInternshipConsultationModel(
      codEmpresa: 1,
      codCarrinhoPercurso: 1,
      item: '001',
      codPercursoEstagio: 1,
      origem: ExpeditionOrigem.separacaoEstoque,
      codOrigem: 1,
      situacao: situation,
      carrinhoAgrupador: Situation.inativo,
      codCarrinho: 55,
      nomeCarrinho: 'CARRINHO 55',
      codigoBarrasCarrinho: '00015520240603',
      ativo: Situation.ativo,
      codUsuarioInicio: 1,
      nomeUsuarioInicio: 'Administrador',
      dataInicio: DateTime.now(),
      horaInicio: '17:26:28',
      nomeSetorEstoque: 'Setor Principal',
    );

    return CartItemCard(
      cart: testCart,
      viewModel: null, // Não usar Provider para o exemplo
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Clicou no carrinho #${testCart.codCarrinho}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      },
    );
  }
}
