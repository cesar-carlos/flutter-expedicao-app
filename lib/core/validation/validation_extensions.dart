import 'validators/model_validators.dart';

import 'package:exp/domain/models/expedition_cancellation_model.dart';
import 'package:exp/domain/models/expedition_cart_model.dart';
import 'package:exp/domain/models/expedition_cart_consultation_model.dart';
import 'package:exp/domain/models/expedition_cart_route_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_model.dart';
import 'package:exp/domain/models/expedition_cart_route_internship_group_model.dart';
import 'package:exp/domain/models/separate_consultation_model.dart';
import 'package:exp/domain/models/separate_model.dart';
import 'package:exp/domain/models/separate_item_model.dart';
import 'package:exp/domain/models/separate_item_consultation_model.dart';
import 'package:exp/domain/models/separation_item_model.dart';
import 'package:exp/domain/models/separation_item_consultation_model.dart';
import 'package:exp/domain/models/user/app_user.dart';
import 'package:exp/domain/models/user/login_request.dart';
import 'package:exp/domain/models/user/create_user_request.dart';
import 'package:exp/domain/models/user/app_user_consultation.dart';

/// Extensions para adicionar validação aos models existentes
/// Permite usar model.validate() e model.isValid diretamente

// === EXPEDITION MODEL EXTENSIONS ===

/// Extension para ExpeditionCancellationModel
extension ExpeditionCancellationValidation on ExpeditionCancellationModel {
  /// Valida o modelo
  String? validate() => ModelValidators.validateExpeditionCancellation(toJson());

  /// Verifica se o modelo é válido
  bool get isValid => validate() == null;

  /// Obtém lista de erros de validação
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para ExpeditionCartModel
extension ExpeditionCartValidation on ExpeditionCartModel {
  String? validate() => ModelValidators.validateExpeditionCart(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para ExpeditionCartConsultationModel
extension ExpeditionCartConsultationValidation on ExpeditionCartConsultationModel {
  String? validate() => ModelValidators.validateExpeditionCartConsultation(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para ExpeditionCartRouteModel
extension ExpeditionCartRouteValidation on ExpeditionCartRouteModel {
  String? validate() => ModelValidators.validateExpeditionCartRoute(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para ExpeditionCartRouteInternshipModel
extension ExpeditionCartRouteInternshipValidation on ExpeditionCartRouteInternshipModel {
  String? validate() => ModelValidators.validateExpeditionCartRouteInternship(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para ExpeditionCartRouteInternshipGroupModel
extension ExpeditionCartRouteInternshipGroupValidation on ExpeditionCartRouteInternshipGroupModel {
  String? validate() => ModelValidators.validateExpeditionCartRouteInternshipGroup(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

// === SEPARATION MODEL EXTENSIONS ===

/// Extension para SeparateConsultationModel
extension SeparateConsultationValidation on SeparateConsultationModel {
  String? validate() => ModelValidators.validateSeparateConsultation(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }

  /// Validação com regras de negócio
  String? validateWithBusinessRules() => ModelValidators.validateSeparationWithBusinessRules(toJson());

  /// Verifica se é válido com regras de negócio
  bool get isValidWithBusinessRules => validateWithBusinessRules() == null;
}

/// Extension para SeparateModel
extension SeparateValidation on SeparateModel {
  String? validate() => ModelValidators.validateSeparate(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para SeparateItemModel
extension SeparateItemValidation on SeparateItemModel {
  String? validate() => ModelValidators.validateSeparateItem(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para SeparateItemConsultationModel
extension SeparateItemConsultationValidation on SeparateItemConsultationModel {
  String? validate() => ModelValidators.validateSeparateItemConsultation(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para SeparationItemModel
extension SeparationItemValidation on SeparationItemModel {
  String? validate() => ModelValidators.validateSeparationItem(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para SeparationItemConsultationModel
extension SeparationItemConsultationValidation on SeparationItemConsultationModel {
  String? validate() => ModelValidators.validateSeparationItemConsultation(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

// === USER MODEL EXTENSIONS ===

/// Extension para AppUser
extension AppUserValidation on AppUser {
  String? validate() => ModelValidators.validateAppUser(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }

  /// Validação com regras de negócio
  String? validateWithBusinessRules() => ModelValidators.validateUserWithBusinessRules(toJson());

  /// Verifica se é válido com regras de negócio
  bool get isValidWithBusinessRules => validateWithBusinessRules() == null;
}

/// Extension para AppUserConsultation
extension AppUserConsultationValidation on AppUserConsultation {
  String? validate() => ModelValidators.validateAppUserConsultation(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para LoginRequest
extension LoginRequestValidation on LoginRequest {
  String? validate() => ModelValidators.validateLoginRequest(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

/// Extension para CreateUserRequest
extension CreateUserRequestValidation on CreateUserRequest {
  String? validate() => ModelValidators.validateCreateUserRequest(toJson());
  bool get isValid => validate() == null;
  List<String> get validationErrors {
    final error = validate();
    return error != null ? [error] : [];
  }
}

// UserPreferences não tem toJson, extensão removida

// === PAGINATION MODEL EXTENSIONS ===

// Pagination não tem toJson, extensão removida

// QueryBuilder não tem toJson, extensão removida

// QueryParam não tem toJson, extensão removida

// QueryOrderBy não existe, extensão removida

// === COLLECTION EXTENSIONS ===

/// Extension para listas de models
extension ModelListValidation<T> on List<T> {
  /// Valida todos os models na lista
  List<String> validateAll() {
    final errors = <String>[];
    for (int i = 0; i < length; i++) {
      final item = this[i];
      String? error;

      // Tenta usar a extension de validação se disponível
      if (item is ExpeditionCancellationModel) {
        error = item.validate();
      } else if (item is SeparateConsultationModel) {
        error = item.validate();
      } else if (item is AppUser) {
        error = item.validate();
      }
      // Adicione outros tipos conforme necessário

      if (error != null) {
        errors.add('Item $i: $error');
      }
    }
    return errors;
  }

  /// Verifica se todos os models na lista são válidos
  bool get areAllValid => validateAll().isEmpty;

  /// Filtra apenas os models válidos
  List<T> get validModels {
    return where((item) {
      if (item is ExpeditionCancellationModel) {
        return item.isValid;
      } else if (item is SeparateConsultationModel) {
        return item.isValid;
      } else if (item is AppUser) {
        return item.isValid;
      }
      return true; // Se não tem validação, considera válido
    }).toList();
  }

  /// Filtra apenas os models inválidos
  List<T> get invalidModels {
    return where((item) {
      if (item is ExpeditionCancellationModel) {
        return !item.isValid;
      } else if (item is SeparateConsultationModel) {
        return !item.isValid;
      } else if (item is AppUser) {
        return !item.isValid;
      }
      return false; // Se não tem validação, considera válido
    }).toList();
  }
}

// === MAP EXTENSIONS ===

/// Extension para Map<String, dynamic> com validações
extension MapValidation on Map<String, dynamic> {
  /// Valida o map como um tipo de modelo específico
  String? validateAs(String modelType) {
    return ModelValidators.validateModel(this, modelType);
  }

  /// Verifica se o map é válido para um tipo de modelo
  bool isValidAs(String modelType) {
    return validateAs(modelType) == null;
  }

  /// Valida campos obrigatórios
  List<String> validateRequiredFields(List<String> requiredFields) {
    final missing = <String>[];
    for (final field in requiredFields) {
      if (!containsKey(field) || this[field] == null) {
        missing.add(field);
      }
    }
    return missing;
  }

  /// Verifica se todos os campos obrigatórios estão presentes
  bool hasRequiredFields(List<String> requiredFields) {
    return validateRequiredFields(requiredFields).isEmpty;
  }
}
