import 'package:flutter/material.dart';
import 'package:exp/ui/widgets/data_grid/separate_data_grid.dart';
import 'package:exp/ui/widgets/data_grid/separate_consultation_data_grid.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';

/// Exemplo de uso dos DataGrids de separação
class SeparateDataGridExample extends StatefulWidget {
  const SeparateDataGridExample({super.key});

  @override
  State<SeparateDataGridExample> createState() =>
      _SeparateDataGridExampleState();
}

class _SeparateDataGridExampleState extends State<SeparateDataGridExample>
    with TickerProviderStateMixin {
  late List<SeparateModel> _separations;
  late List<SeparateConsultationModel> _consultations;
  int _selectedTabIndex = 0;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    _loadSampleData();
  }

  void _loadSampleData() {
    // Dados de exemplo para separações
    _separations = [
      SeparateModel(
        codEmpresa: 1,
        codSepararEstoque: 1001,
        codTipoOperacaoExpedicao: 1,
        tipoEntidade: 'CLIENTE',
        codEntidade: 123,
        nomeEntidade: 'Cliente ABC Ltda',
        situacao: 'PENDENTE',
        data: DateTime.now().subtract(const Duration(days: 1)),
        hora: '09:30:00',
        codPrioridade: 2,
        observacao: 'Separação urgente para entrega',
      ),
      SeparateModel(
        codEmpresa: 1,
        codSepararEstoque: 1002,
        codTipoOperacaoExpedicao: 1,
        tipoEntidade: 'CLIENTE',
        codEntidade: 124,
        nomeEntidade: 'Empresa XYZ S.A.',
        situacao: 'EM_ANDAMENTO',
        data: DateTime.now(),
        hora: '14:15:00',
        codPrioridade: 1,
        observacao: 'Produtos em separação',
      ),
      SeparateModel(
        codEmpresa: 1,
        codSepararEstoque: 1003,
        codTipoOperacaoExpedicao: 1,
        tipoEntidade: 'CLIENTE',
        codEntidade: 125,
        nomeEntidade: 'Comércio DEF',
        situacao: 'FINALIZADA',
        data: DateTime.now().subtract(const Duration(days: 2)),
        hora: '16:45:00',
        codPrioridade: 3,
        observacao: 'Separação concluída com sucesso',
      ),
    ];

    // Dados de exemplo para consultas
    _consultations = [
      SeparateConsultationModel(
        id: 1,
        codigo: 'SEP-001',
        descricao: 'Consulta de separação para cliente ABC',
        status: 'ATIVO',
        dataInicialSeparacao: DateTime.now().subtract(const Duration(days: 1)),
        dataFinalSeparacao: null,
        usuario: 'João Silva',
        observacoes: 'Consulta em andamento',
      ),
      SeparateConsultationModel(
        id: 2,
        codigo: 'SEP-002',
        descricao: 'Consulta de separação para cliente XYZ',
        status: 'FINALIZADO',
        dataInicialSeparacao: DateTime.now().subtract(const Duration(days: 3)),
        dataFinalSeparacao: DateTime.now().subtract(const Duration(days: 2)),
        usuario: 'Maria Santos',
        observacoes: 'Consulta finalizada com sucesso',
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DataGrids de Separação'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Tabs para alternar entre os DataGrids
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Separações'),
              Tab(text: 'Consultas'),
            ],
          ),
          // Conteúdo dos DataGrids
          Expanded(
            child: IndexedStack(
              index: _selectedTabIndex,
              children: [
                // DataGrid de Separações
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Separações de Expedição (${_separations.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SeparateDataGrid(
                          separations: _separations,
                          onRowTap: _onSeparationTap,
                          onRowDoubleTap: _onSeparationDoubleTap,
                        ),
                      ),
                    ],
                  ),
                ),
                // DataGrid de Consultas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultas de Separação (${_consultations.length})',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SeparateConsultationDataGrid(
                          consultations: _consultations,
                          onRowTap: _onConsultationTap,
                          onRowDoubleTap: _onConsultationDoubleTap,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onSeparationTap(SeparateModel separation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Separação ${separation.codSepararEstoque} selecionada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onSeparationDoubleTap(SeparateModel separation) {
    _showSeparationDetails(separation);
  }

  void _onConsultationTap(SeparateConsultationModel consultation) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Consulta ${consultation.codigo} selecionada'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onConsultationDoubleTap(SeparateConsultationModel consultation) {
    _showConsultationDetails(consultation);
  }

  void _showSeparationDetails(SeparateModel separation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Separação ${separation.codSepararEstoque}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cliente: ${separation.nomeEntidade}'),
            Text('Situação: ${separation.situacao}'),
            Text(
              'Data: ${separation.data.day}/${separation.data.month}/${separation.data.year}',
            ),
            Text('Hora: ${separation.hora}'),
            Text('Prioridade: ${separation.codPrioridade}'),
            if (separation.observacao != null)
              Text('Observação: ${separation.observacao}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showConsultationDetails(SeparateConsultationModel consultation) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Consulta ${consultation.codigo}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descrição: ${consultation.descricao}'),
            Text('Status: ${consultation.status}'),
            Text('Usuário: ${consultation.usuario}'),
            if (consultation.observacoes != null)
              Text('Observações: ${consultation.observacoes}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Adicionar Nova Separação'),
        content: const Text(
          'Funcionalidade de adicionar nova separação será implementada aqui.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
