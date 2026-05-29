import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/core/utils/fields_helper.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/status_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

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
          child: Text('Código', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'nomeEntidade',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Cliente', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
      GridColumn(
        columnName: 'situacao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Situação', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'data',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Data', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'hora',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Hora', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 80,
      ),
      GridColumn(
        columnName: 'prioridade',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Prioridade', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'observacao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Observação', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
    ];
  }
}

class ShipmentSeparateDataSource extends DataGridSource {
  final List<SeparateModel> _separations;
  final Function(SeparateModel)? onRowTap;
  final Function(SeparateModel)? onRowDoubleTap;

  ShipmentSeparateDataSource(this._separations, {this.onRowTap, this.onRowDoubleTap});

  /// Item 10: cache da lista de `DataGridRow`.
  ///
  /// O getter `rows` remapeava toda a lista `_separations` a cada acesso.
  /// Como `_separations` é imutável por instância (a fonte é recriada a cada
  /// build), cacheamos de forma lazy; o cache é invalidado naturalmente
  /// quando a fonte/lista muda.
  List<DataGridRow>? _rowsCache;

  @override
  List<DataGridRow> get rows => _rowsCache ??= _buildRows();

  List<DataGridRow> _buildRows() {
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

  /// Cache da lista de separacoes indexada por codSepararEstoque.
  ///
  /// Bug latente anterior:
  /// 1. `rows.indexOf(row)` recomputava o `rows` getter a cada call
  ///    (que mapeia a lista inteira). Em grids com 200+ linhas isso
  ///    custava O(n^2) total para renderizar.
  /// 2. `DataGridRow` nao tem operador == customizado — usa identity.
  ///    Como `rows` getter cria DataGridRows novos a cada call, o
  ///    `indexOf` podia retornar -1, gerando `RangeError` em
  ///    `_separations[-1]`.
  ///
  /// Fix: procurar a separation diretamente pelo valor da primeira
  /// celula ('codigo' = codSepararEstoque.toString()), sem depender
  /// de identidade de DataGridRow.
  SeparateModel? _separationFromRow(DataGridRow row) {
    final cells = row.getCells();
    if (cells.isEmpty) return null;
    final codigoCell = cells.firstWhere(
      (c) => c.columnName == 'codigo',
      orElse: () => cells.first,
    );
    final codigo = codigoCell.value?.toString();
    if (codigo == null) return null;
    for (final s in _separations) {
      if (s.codSepararEstoque.toString() == codigo) return s;
    }
    return null;
  }

  @override
  DataGridRowAdapter? buildRow(DataGridRow row) {
    final separation = _separationFromRow(row);

    return DataGridRowAdapter(
      cells: row.getCells().map<Widget>((dataGridCell) {
        return GestureDetector(
          onTap: (onRowTap != null && separation != null) ? () => onRowTap!(separation) : null,
          onDoubleTap: (onRowDoubleTap != null && separation != null) ? () => onRowDoubleTap!(separation) : null,
          child: Container(
            padding: const EdgeInsets.all(8.0),
            alignment: _getAlignment(dataGridCell.columnName),
            child: dataGridCell.value is Widget
                ? dataGridCell.value as Widget
                : Text(
                    dataGridCell.value?.toString() ?? '',
                    style: AppFonts.inter(fontSize: 12),
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
        style: AppFonts.inter(color: textColor, fontSize: UIConstants.extraSmallFontSize, fontWeight: FontWeight.bold),
      ),
    );
  }

  Color _getTextColor(Color backgroundColor) {
    if (backgroundColor == AppColors.yellow ||
        backgroundColor == AppColors.lightGreen ||
        backgroundColor == AppColors.warning ||
        backgroundColor == AppColors.info) {
      return AppColors.black;
    }

    return AppColors.white;
  }

  Widget _buildPrioridadeChip(int prioridade) {
    Color backgroundColor;
    String text;

    switch (prioridade) {
      case 1:
        backgroundColor = AppColors.success;
        text = 'Baixa';
        break;
      case 2:
        backgroundColor = AppColors.yellow;
        text = 'Média';
        break;
      case 3:
        backgroundColor = AppColors.warning;
        text = 'Alta';
        break;
      case 4:
        backgroundColor = AppColors.error;
        text = 'Urgente';
        break;
      default:
        backgroundColor = AppColors.grey;
        text = 'N/A';
    }

    final textColor = _getTextColor(backgroundColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
      child: Text(
        text,
        style: AppFonts.inter(color: textColor, fontSize: UIConstants.extraSmallFontSize, fontWeight: FontWeight.bold),
      ),
    );
  }
}
