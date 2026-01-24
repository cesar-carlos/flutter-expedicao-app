import 'package:zard/zard.dart';

import 'package:data7_expedicao/l10n/app_localizations.dart';
import 'package:data7_expedicao/domain/models/situation/expedition_situation_model.dart';
import 'package:data7_expedicao/domain/models/expedition_origem_model.dart';
import 'package:data7_expedicao/domain/models/entity_type_model.dart';

class FormValidatorsLocalized {
  final AppLocalizations l10n;

  FormValidatorsLocalized(this.l10n);

  Schema<String> _usernameSchema() {
    return z.string().min(1, message: l10n.usernameRequired).transform((value) => value.trim());
  }

  Schema<String> _passwordSchema() {
    return z
        .string()
        .min(1, message: l10n.passwordRequired)
        .min(4, message: l10n.passwordMinLength(4))
        .max(60, message: l10n.passwordMaxLength(60));
  }

  Schema<String> _nameSchema() {
    return z
        .string()
        .min(1, message: l10n.nameRequired)
        .transform((value) => value.trim())
        .refine((value) => value.length <= 30, message: l10n.nameMaxLength(30));
  }

  Schema<String> _emailSchema() {
    return z
        .string()
        .min(1, message: l10n.emailRequired)
        .email(message: l10n.emailInvalid)
        .transform((value) => value.trim());
  }

  Schema<String> _apiUrlSchema() {
    return z.string().min(1, message: l10n.urlRequired).transform((value) => value.trim());
  }

  Schema<String> _apiPortSchema() {
    return z.string().min(1, message: l10n.portRequired).transform((value) => value.trim()).refine((value) {
      final port = int.tryParse(value);
      return port != null && port >= 1 && port <= 65535;
    }, message: l10n.portInvalid);
  }

  String? username(String? value) {
    try {
      _usernameSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? password(String? value) {
    try {
      _passwordSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? name(String? value) {
    try {
      _nameSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? email(String? value) {
    try {
      _emailSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? confirmPassword(String? value, String? originalPassword) {
    if (originalPassword == null) return l10n.passwordRequired;

    try {
      z
          .map({'password': z.string(), 'confirmPassword': z.string().min(1, message: l10n.confirmPasswordRequired)})
          .refine((data) {
            return data['confirmPassword'] == data['password'];
          }, message: l10n.passwordsDoNotMatch)
          .parse({'password': originalPassword, 'confirmPassword': value ?? ''});
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? apiUrl(String? value) {
    try {
      _apiUrlSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? apiPort(String? value) {
    try {
      _apiPortSchema().parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? codSepararEstoque(String? value) {
    try {
      z
          .string()
          .optional()
          .transform((value) {
            if (value.trim().isEmpty) return null;
            return value.trim();
          })
          .refine((value) {
            if (value == null) return true;
            return int.tryParse(value) != null;
          }, message: l10n.codeMustBeNumeric)
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? origem(String? value) {
    try {
      z
          .string()
          .optional()
          .refine((value) {
            if (value.isEmpty) return true;
            return ExpeditionOrigem.isValidOrigem(value);
          }, message: l10n.invalidOrigin)
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? situacao(String? value) {
    try {
      z
          .string()
          .optional()
          .refine((value) {
            if (value.isEmpty) return true;
            return ExpeditionSituation.isValidSituation(value);
          }, message: l10n.invalidSituation)
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  String? tipoEntidade(String? value) {
    try {
      z
          .string()
          .refine((value) {
            return EntityType.isValidType(value);
          }, message: l10n.invalidEntityType)
          .parse(value);
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}
