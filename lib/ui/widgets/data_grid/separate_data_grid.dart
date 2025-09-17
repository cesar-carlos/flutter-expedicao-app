import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/models/expedition_situation_model.dart';
import 'package:exp/core/utils/fields_helper.dart';

/// DataGrid para exibir separações de expedição
class SeparateDataGrid extends StatelessWidget {
  final List<SeparateModel> separations;
  final Function(SeparateModel)? onRowTap;
  final Function(SeparateModel)? onRowDoubleTap;
  final bool allowSorting;
  final bool allowFiltering;
  final bool allowSelection;

  const SeparateDataGrid({
    super.key,
    required this.separations,
    this.onRowTap,
    this.onRowDoubleTap,
    this.allowSorting = true,
    this.allowFiltering = true,
    this.allowSelection = true,
  });

  @override
  Widget build(BuildContext context) {
    return SfDataGrid(
      source: ShipmentSeparateDataSource(separations, onRowTap: onRowTap, onRowDoubleTap: onRowDoubleTap),
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
        columnName: 'codigo',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text('Código', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'nomeEntidade',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text('Cliente', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
      GridColumn(
        columnName: 'situacao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Situação', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'data',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Data', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'hora',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Hora', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 80,
      ),
      GridColumn(
        columnName: 'prioridade',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text('Prioridade', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'observacao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text('Observação', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
    ];
  }
}

/// DataSource para o DataGrid de separações
class ShipmentSeparateDataSource extends DataGridSource {
  final List<SeparateModel> _separations;
  final Function(SeparateModel)? onRowTap;
  final Function(SeparateModel)? onRowDoubleTap;

  ShipmentSeparateDataSource(this._separations, {this.onRowTap, this.onRowDoubleTap});

  @override
  List<DataGridRow> get rows {
    return _separations.map<DataGridRow>((separation) {
      return DataGridRow(
        cells: [
          DataGridCell<String>(columnName: 'codigo', value: separation.codSepararEstoque.toString()),
          DataGridCell<String>(columnName: 'nomeEntidade', value: separation.nomeEntidade),
          DataGridCell<Widget>(columnName: 'situacao', value: _buildSituacaoChip(separation.situacao)),
          DataGridCell<String>(columnName: 'data', value: FieldsHelper.formatDataBrasileira(separation.data)),
          DataGridCell<String>(columnName: 'hora', value: separation.hora),
          DataGridCell<Widget>(columnName: 'prioridade', value: _buildPrioridadeChip(separation.codPrioridade)),
          DataGridCell<String>(columnName: 'observacao', value: separation.observacao ?? ''),
        ],
      );
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final rowIndex = rows.indexOf(row);
    final separation = _separations[rowIndex];

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return GestureDetector(
          onTap: onRowTap != null ? () => onRowTap!(separation) : null,
          onDoubleTap: onRowDoubleTap != null ? () => onRowDoubleTap!(separation) : null,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: _getAlignment(dataGridCell.columnName),
            child: dataGridCell.value is Widget
                ? dataGridCell.value as Widget
                : Text(
                    dataGridCell.value?.toString() ?? '',
                    style: const TextStyle(fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
          ),
        );
      }).toList(),
    );
  }

  Alignment _getAlignment(String columnName) {
    switch (columnName) {
      case 'codigo':
      case 'situacao':
      case 'data':
      case 'hora':
      case 'prioridade':
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  Widget _buildSituacaoChip(ExpeditionSituation situacao) {
    final backgroundColor = situacao.color;
    final textColor = _getTextColor(backgroundColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        situacao.description,
        style: TextStyle(color: textColor, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
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

  Widget _buildPrioridadeChip(int prioridade) {
    Color backgroundColor;
    String text;

    switch (prioridade) {
      case 1:
        backgroundColor = Colors.green;
        text = 'Baixa';
        break;
      case 2:
        backgroundColor = Colors.yellow;
        text = 'Média';
        break;
      case 3:
        backgroundColor = Colors.orange;
        text = 'Alta';
        break;
      case 4:
        backgroundColor = Colors.red;
        text = 'Urgente';
        break;
      default:
        backgroundColor = Colors.grey;
        text = 'N/A';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
