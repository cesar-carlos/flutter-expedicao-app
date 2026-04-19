import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import 'package:data7_expedicao/domain/models/separate_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/core/utils/fields_helper.dart';
import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';
import 'package:data7_expedicao/core/constants/ui_constants.dart';

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
      source: ShipmentSeparateConsultationDataSource(consultations, onRowTap: onRowTap, onRowDoubleTap: onRowDoubleTap),
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
          child: Text('Cód. Separação', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'codigo',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Cód. Empresa', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 100,
      ),
      GridColumn(
        columnName: 'descricao',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Tipo Operação', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 180,
      ),
      GridColumn(
        columnName: 'status',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Situação', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'dataInicial',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Data Emissão', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 120,
      ),
      GridColumn(
        columnName: 'dataFinal',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.center,
          child: Text('Data/Hora', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 150,
      ),
      GridColumn(
        columnName: 'usuario',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Entidade', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
      GridColumn(
        columnName: 'observacoes',
        label: Container(
          padding: const EdgeInsets.all(8.0),
          alignment: Alignment.centerLeft,
          child: Text('Observações', style: AppFonts.inter(fontWeight: FontWeight.bold)),
        ),
        width: 200,
      ),
    ];
  }
}

class ShipmentSeparateConsultationDataSource extends DataGridSource {
  final List<SeparateConsultationModel> _consultations;
  final Function(SeparateConsultationModel)? onRowTap;
  final Function(SeparateConsultationModel)? onRowDoubleTap;

  ShipmentSeparateConsultationDataSource(this._consultations, {this.onRowTap, this.onRowDoubleTap});

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
      final dataFinal = '${_formatDateSafe(consultation.dataEmissao)} ${consultation.horaEmissao}';
      final usuario = consultation.nomeEntidade;
      final observacoes = consultation.observacao ?? '';

      return DataGridRow(
        cells: [
          DataGridCell<int>(columnName: 'id', value: id),
          DataGridCell<String>(columnName: 'codigo', value: codigo),
          DataGridCell<String>(columnName: 'descricao', value: descricao),
          DataGridCell<Widget>(columnName: 'status', value: _buildStatusChipSafe(status)),
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
              child: Text('ERRO: Índice inválido', style: AppFonts.inter(fontSize: 12, color: AppColors.error)),
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

            cellWidget = Text(valueText, style: AppFonts.inter(fontSize: 12), overflow: TextOverflow.ellipsis);
          }

          cells.add(
            GestureDetector(
              onTap: onRowTap != null ? () => onRowTap!(consultation) : null,
              onDoubleTap: onRowDoubleTap != null ? () => onRowDoubleTap!(consultation) : null,
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
                style: AppFonts.inter(fontSize: UIConstants.extraSmallFontSize, color: AppColors.error),
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
              style: AppFonts.inter(fontSize: UIConstants.extraSmallFontSize, color: AppColors.error),
            ),
          ),
        ),
      );
    }
  }

  /// Encontra o indice da consulta correspondente ao `DataGridRow`.
  ///
  /// Bug de performance anterior: chamava `rows.indexOf(row)` PRIMEIRO,
  /// que recomputava o getter `rows` (mapeia toda a lista
  /// `_consultations`) a cada call. Em grids com 200+ linhas isso
  /// custava O(n^2) total. O fallback por `id` ja existia mas so
  /// rodava se o `indexOf` falhasse — agora colocamos o fallback
  /// (lookup por id) como caminho primario porque e O(n) garantido
  /// e nao depende de identidade de DataGridRow (que e recriado a
  /// cada call do getter rows).
  int _findRowIndex(DataGridRow row) {
    try {
      final rowCells = row.getCells();
      if (rowCells.isEmpty) return -1;

      final firstCell = rowCells.first;
      if (firstCell.columnName == 'id' && firstCell.value is int) {
        final idValue = firstCell.value as int;
        for (int i = 0; i < _consultations.length; i++) {
          if (_consultations[i].codSepararEstoque == idValue) {
            return i;
          }
        }
      }

      // Ultima tentativa: identity match (raramente matcha porque
      // o getter `rows` cria DataGridRows novos a cada call, mas
      // mantemos por seguranca em caso do syncfusion otimizar).
      final directIndex = rows.indexOf(row);
      return directIndex;
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

  Widget _buildStatusChipFromEnum(ExpeditionSituation status) {
    try {
      final backgroundColor = status.color;
      final textColor = _getTextColor(backgroundColor);
      final description = status.description;

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(12)),
        child: Text(
          description,
          style: AppFonts.inter(
            color: textColor,
            fontSize: UIConstants.extraSmallFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    } catch (e) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.grey, borderRadius: BorderRadius.circular(12)),
        child: Text(
          'Erro',
          style: AppFonts.inter(
            color: AppColors.white,
            fontSize: UIConstants.extraSmallFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
  }

  Widget _buildStatusChipSafe(ExpeditionSituation? status) {
    try {
      if (status == null) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(12)),
          child: Text(
            'N/A',
            style: AppFonts.inter(
              color: Colors.white,
              fontSize: UIConstants.extraSmallFontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }

      return _buildStatusChipFromEnum(status);
    } catch (e) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(12)),
        child: Text(
          'ERRO',
          style: AppFonts.inter(
            color: AppColors.white,
            fontSize: UIConstants.extraSmallFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }
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
}
