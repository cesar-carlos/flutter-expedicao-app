import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_colors.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check.dart';
import 'package:data7_expedicao/domain/models/expedition_check_cart_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check_consultation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_check_item_consultation_model.dart';
import 'package:data7_expedicao/domain/models/separate_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_model.dart';
import 'package:data7_expedicao/domain/models/separation_item_status.dart';
import 'package:data7_expedicao/domain/models/separation_user_sector_consultation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_router_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_cart_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_item_situation_model.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';

// Mapeamento de cor dos status/situacoes de dominio para a camada de
// tema/UI. O dominio permanece livre de Flutter; aqui resolvemos a cor
// usando exatamente os mesmos valores de AppColors que existiam antes.

extension SeparationItemStatusColors on SeparationItemStatus {
  Color get color => switch (this) {
        SeparationItemStatus.separado => AppColors.success,
        SeparationItemStatus.pendente => AppColors.warning,
        SeparationItemStatus.parcial => AppColors.info,
        SeparationItemStatus.cancelado => AppColors.error,
      };

  static List<Color> get colors => SeparationItemStatus.availableForFilter.map((e) => e.color).toList();
}

extension EntityTypeColors on EntityType {
  Color get color => switch (this) {
        EntityType.cliente => AppColors.info,
        EntityType.fornecedor => AppColors.success,
      };

  static Color colorFromCode(String code) => EntityType.fromCode(code)?.color ?? AppColors.grey;
}

extension EntityTypeColorString on String {
  Color get entityTypeColor => EntityType.fromCode(this)?.color ?? AppColors.grey;
}

extension ExpeditionSituationColors on ExpeditionSituation {
  Color get color => switch (this) {
        ExpeditionSituation.aguardando => AppColors.grey,
        ExpeditionSituation.emPausa => AppColors.yellow,
        ExpeditionSituation.cancelada => AppColors.error,
        ExpeditionSituation.separando => AppColors.warning,
        ExpeditionSituation.separado => AppColors.lightGreen,
        ExpeditionSituation.conferindo => AppColors.purple,
        ExpeditionSituation.conferido => AppColors.lightGreen,
        ExpeditionSituation.entregue => AppColors.success,
        ExpeditionSituation.embalando => AppColors.teal,
        ExpeditionSituation.embalado => AppColors.teal,
        ExpeditionSituation.agrupado => AppColors.error,
        ExpeditionSituation.finalizada => AppColors.success,
        ExpeditionSituation.naoLocalizada => AppColors.error,
      };

  static Color colorFromCode(String code) => ExpeditionSituation.fromCode(code)?.color ?? AppColors.grey;
}

extension ExpeditionItemSituationColors on ExpeditionItemSituation {
  Color get color => switch (this) {
        ExpeditionItemSituation.separado => AppColors.lightGreen,
        ExpeditionItemSituation.cancelado => AppColors.error,
        ExpeditionItemSituation.pendente => AppColors.grey,
        ExpeditionItemSituation.conferido => AppColors.lightGreen,
        ExpeditionItemSituation.embalado => AppColors.teal,
        ExpeditionItemSituation.entregue => AppColors.success,
        ExpeditionItemSituation.expedido => AppColors.success,
        ExpeditionItemSituation.pausado => AppColors.yellow,
        ExpeditionItemSituation.reiniciado => AppColors.info,
        ExpeditionItemSituation.finalizado => AppColors.success,
        ExpeditionItemSituation.armazenar => AppColors.brown,
        ExpeditionItemSituation.vazio => AppColors.grey,
      };

  static Color colorFromCode(String code) => ExpeditionItemSituation.fromCode(code)?.color ?? AppColors.grey;
}

extension ExpeditionCartSituationColors on ExpeditionCartSituation {
  Color get color => switch (this) {
        ExpeditionCartSituation.liberado => AppColors.info,
        ExpeditionCartSituation.emSeparacao => AppColors.warning,
        ExpeditionCartSituation.separado => AppColors.success,
        ExpeditionCartSituation.emConferencia => AppColors.purple,
        ExpeditionCartSituation.conferindo => AppColors.lightGreen,
        ExpeditionCartSituation.emEntrega => AppColors.error,
        ExpeditionCartSituation.emPausa => AppColors.yellow,
        ExpeditionCartSituation.vazio => AppColors.grey,
      };
}

extension ExpeditionCartRouterSituationColors on ExpeditionCartRouterSituation {
  Color get color => switch (this) {
        ExpeditionCartRouterSituation.cancelada => AppColors.error,
        ExpeditionCartRouterSituation.conferido => AppColors.lightGreen,
        ExpeditionCartRouterSituation.emConferencia => AppColors.purple,
        ExpeditionCartRouterSituation.emEntrega => AppColors.teal,
        ExpeditionCartRouterSituation.entregue => AppColors.yellow,
        ExpeditionCartRouterSituation.emSeparacao => AppColors.warning,
        ExpeditionCartRouterSituation.finalizada => AppColors.success,
        ExpeditionCartRouterSituation.separado => AppColors.lightGreen,
        ExpeditionCartRouterSituation.embalado => AppColors.teal,
        ExpeditionCartRouterSituation.vazio => AppColors.grey,
      };

  static Color colorFromCode(String code) => ExpeditionCartRouterSituation.fromCode(code)?.color ?? AppColors.grey;
}

// Getters de cor equivalentes aos que existiam nos models de dominio.

extension SeparateModelColors on SeparateModel {
  Color get situacaoColor => situacao.color;
}

extension SeparationItemModelColors on SeparationItemModel {
  Color get situacaoColor => situacao.color;
}

extension SeparationUserSectorConsultationModelColors on SeparationUserSectorConsultationModel {
  Color get situacaoColor => separarEstoqueSituacao.color;
}

extension ExpeditionCheckModelColors on ExpeditionCheckModel {
  Color get situacaoColor => situacao.color;
}

extension ExpeditionCheckConsultationModelColors on ExpeditionCheckConsultationModel {
  Color get situacaoColor => situacao.color;
  Color get tipoEntidadeColor => tipoEntidade.color;
}

extension ExpeditionCheckItemConsultationModelColors on ExpeditionCheckItemConsultationModel {
  Color get situacaoCarrinhoPercursoColor => situacaoCarrinhoPercurso.color;
}

extension ExpeditionCheckCartConsultationModelColors on ExpeditionCheckCartConsultationModel {
  Color get situacaoColor => situacao.color;
  Color get situacaoCarrinhoConferenciaColor => situacaoCarrinhoConferencia.color;
}
