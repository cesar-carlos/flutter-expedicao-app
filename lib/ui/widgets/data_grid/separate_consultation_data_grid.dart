import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/shipping_situation_model.dart';
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
            'ID',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 80,
      ),
      GridColumn(
        columnName: 'codigo',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Código',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'descricao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Descrição',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 200,
      ),
      GridColumn(
        columnName: 'status',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: const Text(
            'Status',
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
            'Data Inicial',
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
            'Data Final',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'usuario',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: const Text(
            'Usuário',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        width: 150,
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
    return _consultations.map<DataGridRow>((consultation) {
      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: consultation.id),
          DataGridCell<String>(
            columnName: 'codigo',
            value: consultation.codigo ?? '',
          ),
          DataGridCell<String>(
            columnName: 'descricao',
            value: consultation.descricao ?? '',
          ),
          DataGridCell<Widget>(
            columnName: 'status',
            value: _buildStatusChip(consultation.status ?? ''),
          ),
          DataGridCell<String>(
            columnName: 'dataInicial',
            value: consultation.dataInicialSeparacao != null
                ? _formatDate(consultation.dataInicialSeparacao!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'dataFinal',
            value: consultation.dataFinalSeparacao != null
                ? _formatDate(consultation.dataFinalSeparacao!)
                : '',
          ),
          DataGridCell<String>(
            columnName: 'usuario',
            value: consultation.usuario ?? '',
          ),
          DataGridCell<String>(
            columnName: 'observacoes',
            value: consultation.observacoes ?? '',
          ),
        ],
      );
    }).toList();
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final rowIndex = rows.indexOf(row);
    final consultation = _consultations[rowIndex];

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return GestureDetector(
          onTap: onRowTap != null ? () => onRowTap!(consultation) : null,
          onDoubleTap: onRowDoubleTap != null
              ? () => onRowDoubleTap!(consultation)
              : null,
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
      case 'id':
      case 'status':
      case 'dataInicial':
      case 'dataFinal':
        return Alignment.center;
      default:
        return Alignment.centerLeft;
    }
  }

  String _formatDate(DateTime date) {
    return FieldsHelper.formatDataBrasileira(date);
  }

  Widget _buildStatusChip(String status) {
    final situation = ExpeditionSituation.fromCode(status);
    final backgroundColor = situation?.color ?? Colors.grey;
    final textColor = _getTextColor(backgroundColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        ExpeditionSituation.getDescription(status),
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
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
}
