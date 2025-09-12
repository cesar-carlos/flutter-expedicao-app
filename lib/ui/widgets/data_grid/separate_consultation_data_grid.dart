import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/core/utils/fields_helper.dart';

/// DataGrid para exibir consultas de separação de expedição
class SeparateConsultationDataGrid extends StatelessWidget {
  final List<SeparateConsultationModel> consultations;
  final Function(SeparateConsultationModel)? onRowTap;
  final Function(SeparateConsultationModel)? onRowDoubleTap;

  final bool allowSorting;
  final bool allowFiltering;
  final bool allowSelection;

  const SeparateConsultationDataGrid({
    super.key,
    required this.consultations,
    this.onRowTap,
    this.onRowDoubleTap,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.allowSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: ShipmentSeparateConsultationDataSource(
        consultations,
        onRowTap: onRowTap,
        onRowDoubleTap: onRowDoubleTap,
      ),
      allowSorting: allowSorting,
      allowFiltering: allowFiltering,
      allowMultiColumnSorting: true,
      allowTriStateSorting: true,
      selectionMode: allowSelection ? SelectionMode.single : SelectionMode.none,
      columns: _buildColumns(),
      headerRowHeight: 50,
      rowHeight: 40,
      gridLinesVisibility: GridLinesVisibility.both,
      headerGridLinesVisibility: GridLinesVisibility.both,
      columnWidthMode: ColumnWidthMode.fill,
    );
  }

  List<GridColumn> _buildColumns() {
    return [
      GridColumn(
        columnName: 'id',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'Cód. Separação',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'codigo',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Cód. Empresa',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'descricao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Tipo Operação',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 180,
      ),
      GridColumn(
        columnName: 'status',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'Situação',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'dataInicial',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'Data Emissão',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'dataFinal',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'Data/Hora',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 150,
      ),
      GridColumn(
        columnName: 'usuario',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Entidade',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 200,
      ),
      GridColumn(
        columnName: 'observacoes',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Observações',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 200,
      ),
    ];
  }
}

/// DataSource para o DataGrid de consultas de separação
class ShipmentSeparateConsultationDataSource extends DataGridSource {
  final List<SeparateConsultationModel> _consultations;
  final Function(SeparateConsultationModel)? onRowTap;
  final Function(SeparateConsultationModel)? onRowDoubleTap;

  ShipmentSeparateConsultationDataSource(
    this._consultations, {
    this.onRowTap,
    this.onRowDoubleTap,
  });

  @override
  List<DataGridRow> get rows {
    if (_consultations.isEmpty) {
      return [];
    }

    return _consultations.map<DataGridRow>((consultation) {
      final id = consultation.codSepararEstoque;
      final codigo = consultation.codEmpresa.toString();
      final descricao = consultation.nomeTipoOperacaoExpedicao;
      final status = consultation.situacao;
      final dataInicial = _formatDateSafe(consultation.dataEmissao);
      final dataFinal =
          '${_formatDateSafe(consultation.dataEmissao)} ${consultation.horaEmissao}';
      final usuario = consultation.nomeEntidade;
      final observacoes = consultation.observacao ?? '';

      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: id),
          DataGridCell<String>(columnName: 'codigo', value: codigo),
          DataGridCell<String>(columnName: 'descricao', value: descricao),
          DataGridCell<Widget>(
            columnName: 'status',
            value: _buildStatusChipSafe(status),
          ),
          DataGridCell<String>(columnName: 'dataInicial', value: dataInicial),
          DataGridCell<String>(columnName: 'dataFinal', value: dataFinal),
          DataGridCell<String>(columnName: 'usuario', value: usuario),
          DataGridCell<String>(columnName: 'observacoes', value: observacoes),
        ],
      );
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    try {
      final rowIndex = _findRowIndex(row);

      if (rowIndex < 0 || rowIndex >= _consultations.length) {
        return DataGridRowAdapter(
          cells: List.generate(
            8,
            (index) => Container(
              padding: const EdgeInsets.all(8.0),
              child: const Text(
                'ERRO: Índice inválido',
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ),
          ),
        );
      }

      final consultation = _consultations[rowIndex];
      final cells = <Widget>[];
      final rowCells = row.getCells();

      for (int i = 0; i < rowCells.length; i++) {
        final dataGridCell = rowCells[i];

        try {
          Widget cellWidget;

          if (dataGridCell.value is Widget) {
            cellWidget = dataGridCell.value as Widget;
          } else {
            final valueText = dataGridCell.value?.toString() ?? '';

            cellWidget = Text(
              valueText,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            );
          }

          cells.add(
            GestureDetector(
              onTap: onRowTap != null ? () => onRowTap!(consultation) : null,
              onDoubleTap: onRowDoubleTap != null
                  ? () => onRowDoubleTap!(consultation)
                  : null,
              child: Container(
                padding: const EdgeInsets.all(8.0),
                alignment: _getAlignment(dataGridCell.columnName),
                child: cellWidget,
              ),
            ),
          );
        } catch (e) {
          cells.add(
            Container(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'ERRO: $e',
                style: const TextStyle(fontSize: 10, color: Colors.red),
              ),
            ),
          );
        }
      }

      return DataGridRowAdapter(cells: cells);
    } catch (e) {
      return DataGridRowAdapter(
        cells: List.generate(
          8,
          (index) => Container(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'ERRO GERAL: $e',
              style: const TextStyle(fontSize: 10, color: Colors.red),
            ),
          ),
        ),
      );
    }
  }

  /// Encontra o índice da linha de forma mais confiável
  int _findRowIndex(DataGridRow row) {
    try {
      // Primeiro, tenta usar o indexOf normal
      final directIndex = rows.indexOf(row);
      if (directIndex >= 0) {
        return directIndex;
      }

      // Se não encontrou, tenta comparar as células para encontrar a linha correspondente
      final rowCells = row.getCells();
      if (rowCells.isEmpty) {
        return -1;
      }

      // Procura pela primeira célula (ID) para encontrar a linha correspondente
      final firstCell = rowCells.first;
      if (firstCell.columnName == 'id' && firstCell.value is int) {
        final idValue = firstCell.value as int;

        for (int i = 0; i < _consultations.length; i++) {
          if (_consultations[i].codSepararEstoque == idValue) {
            return i;
          }
        }
      }

      return -1;
    } catch (e) {
      return -1;
    }
  }

  Alignment _getAlignment(String columnName) {
    switch (columnName) {
      case 'id':
      case 'status':
      case 'dataInicial':
      case 'dataFinal':
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  String _formatDateSafe(DateTime? date) {
    try {
      if (date == null) {
        return '--/--/----';
      }

      return FieldsHelper.formatDataBrasileira(date);
    } catch (e) {
      return 'Erro na data';
    }
  }

  Widget _buildStatusChip(String status) {
    try {
      final situation = ExpeditionSituation.fromCode(status);
      final backgroundColor = situation?.color ?? Colors.grey;
      final textColor = _getTextColor(backgroundColor);
      final description = ExpeditionSituation.getDescription(status);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          description,
          style: TextStyle(
            color: textColor,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Erro',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildStatusChipSafe(String? status) {
    try {
      if (status == null || status.isEmpty) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            'N/A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      return _buildStatusChip(status);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'ERRO',
          style: TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  /// Determina a cor do texto baseada na cor de fundo
  Color _getTextColor(Color backgroundColor) {
    // Cores que precisam de texto preto
    if (backgroundColor == Colors.yellow ||
        backgroundColor == Colors.lightGreen ||
        backgroundColor == Colors.amber ||
        backgroundColor == Colors.lightBlue) {
      return Colors.black;
    }

    return Colors.white;
  }
}
