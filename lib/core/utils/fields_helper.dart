import 'package:intl/intl.dart';
import 'package:brasil_fields/brasil_fields.dart';

/// Utilitário para formatação de dados brasileiros
class FieldsHelper {
  /// Formata CPF
  static String formatCPF(String cpf) {
    final cleanCpf = removeAllFormatting(cpf);
    if (cleanCpf.length == 11) {
      return '${cleanCpf.substring(0, 3)}.${cleanCpf.substring(3, 6)}.${cleanCpf.substring(6, 9)}-${cleanCpf.substring(9)}';
    }
    return cpf;
  }

  /// Formata CNPJ
  static String formatCNPJ(String cnpj) {
    final cleanCnpj = removeAllFormatting(cnpj);
    if (cleanCnpj.length == 14) {
      return '${cleanCnpj.substring(0, 2)}.${cleanCnpj.substring(2, 5)}.${cleanCnpj.substring(5, 8)}/${cleanCnpj.substring(8, 12)}-${cleanCnpj.substring(12)}';
    }
    return cnpj;
  }

  /// Formata CEP
  static String formatCEP(String cep) {
    final cleanCep = removeAllFormatting(cep);
    if (cleanCep.length == 8) {
      return '${cleanCep.substring(0, 5)}-${cleanCep.substring(5)}';
    }
    return cep;
  }

  /// Formata telefone
  static String formatTelefone(String telefone) {
    final cleanTelefone = removeAllFormatting(telefone);
    if (cleanTelefone.length == 11) {
      return '(${cleanTelefone.substring(0, 2)}) ${cleanTelefone.substring(2, 7)}-${cleanTelefone.substring(7)}';
    } else if (cleanTelefone.length == 10) {
      return '(${cleanTelefone.substring(0, 2)}) ${cleanTelefone.substring(2, 6)}-${cleanTelefone.substring(6)}';
    }
    return telefone;
  }

  /// Formata moeda brasileira
  static String formatMoeda(double valor) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return formatter.format(valor);
  }

  /// Formata moeda brasileira a partir de string
  static String formatMoedaFromString(String valor) {
    try {
      final doubleValue = double.parse(valor);
      return formatMoeda(doubleValue);
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  /// Remove formatação de CPF
  static String removeCPFFormatting(String cpf) {
    return removeAllFormatting(cpf);
  }

  /// Remove formatação de CNPJ
  static String removeCNPJFormatting(String cnpj) {
    return removeAllFormatting(cnpj);
  }

  /// Remove formatação de CEP
  static String removeCEPFormatting(String cep) {
    return removeAllFormatting(cep);
  }

  /// Remove formatação de telefone
  static String removeTelefoneFormatting(String telefone) {
    return removeAllFormatting(telefone);
  }

  /// Remove formatação de moeda
  static String removeMoedaFormatting(String moeda) {
    return removeAllFormatting(moeda);
  }

  /// Valida CPF
  static bool isValidCPF(String cpf) {
    final cleanCpf = removeAllFormatting(cpf);
    if (cleanCpf.length != 11) return false;

    // Verifica se todos os dígitos são iguais
    if (cleanCpf.split('').every((digit) => digit == cleanCpf[0])) return false;

    // Validação do CPF
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cleanCpf[i]) * (10 - i);
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleanCpf[9]) != firstDigit) return false;

    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cleanCpf[i]) * (11 - i);
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cleanCpf[10]) == secondDigit;
  }

  /// Valida CNPJ
  static bool isValidCNPJ(String cnpj) {
    final cleanCnpj = removeAllFormatting(cnpj);
    if (cleanCnpj.length != 14) return false;

    // Verifica se todos os dígitos são iguais
    if (cleanCnpj.split('').every((digit) => digit == cleanCnpj[0])) return false;

    // Validação do CNPJ
    int sum = 0;
    int weight = 2;
    for (int i = 11; i >= 0; i--) {
      sum += int.parse(cleanCnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    int remainder = sum % 11;
    int firstDigit = remainder < 2 ? 0 : 11 - remainder;

    if (int.parse(cleanCnpj[12]) != firstDigit) return false;

    sum = 0;
    weight = 2;
    for (int i = 12; i >= 0; i--) {
      sum += int.parse(cleanCnpj[i]) * weight;
      weight = weight == 9 ? 2 : weight + 1;
    }
    remainder = sum % 11;
    int secondDigit = remainder < 2 ? 0 : 11 - remainder;

    return int.parse(cleanCnpj[13]) == secondDigit;
  }

  /// Valida CEP
  static bool isValidCEP(String cep) {
    final cleanCep = removeAllFormatting(cep);
    return cleanCep.length == 8 && RegExp(r'^\d{8}$').hasMatch(cleanCep);
  }

  /// Valida telefone
  static bool isValidTelefone(String telefone) {
    final cleanTelefone = removeAllFormatting(telefone);
    return cleanTelefone.length == 10 || cleanTelefone.length == 11;
  }

  /// Formata CPF com máscara
  static String formatCPFWithMask(String cpf) {
    return formatCPF(cpf);
  }

  /// Formata CNPJ com máscara
  static String formatCNPJWithMask(String cnpj) {
    return formatCNPJ(cnpj);
  }

  /// Formata CEP com máscara
  static String formatCEPWithMask(String cep) {
    return formatCEP(cep);
  }

  /// Formata telefone com máscara
  static String formatTelefoneWithMask(String telefone) {
    return formatTelefone(telefone);
  }

  /// Formata moeda com máscara
  static String formatMoedaWithMask(String valor) {
    try {
      final doubleValue = double.parse(valor);
      return formatMoeda(doubleValue);
    } catch (e) {
      return 'R\$ 0,00';
    }
  }

  /// Converte string para double removendo formatação de moeda
  static double parseMoedaToDouble(String moeda) {
    try {
      final cleanMoeda = removeAllFormatting(moeda);
      return double.parse(cleanMoeda) / 100; // Assume que está em centavos
    } catch (e) {
      return 0.0;
    }
  }

  /// Converte double para string de moeda formatada
  static String parseDoubleToMoeda(double valor) {
    return formatMoeda(valor);
  }

  /// Formata data brasileira (DD/MM/AAAA)
  static String formatDataBrasileira(DateTime data) {
    return '${data.day.toString().padLeft(2, '0')}/'
        '${data.month.toString().padLeft(2, '0')}/'
        '${data.year}';
  }

  /// Formata hora brasileira (HH:MM)
  static String formatHoraBrasileira(DateTime hora) {
    return '${hora.hour.toString().padLeft(2, '0')}:'
        '${hora.minute.toString().padLeft(2, '0')}';
  }

  /// Formata data e hora brasileira (DD/MM/AAAA HH:MM)
  static String formatDataHoraBrasileira(DateTime dataHora) {
    return '${formatDataBrasileira(dataHora)} ${formatHoraBrasileira(dataHora)}';
  }

  /// Remove todos os caracteres especiais de uma string
  static String removeAllFormatting(String texto) {
    return UtilBrasilFields.removeCaracteres(texto);
  }

  /// Formata número de documento (CPF ou CNPJ baseado no tamanho)
  static String formatDocumento(String documento) {
    final cleanDoc = removeAllFormatting(documento);

    if (cleanDoc.length == 11) {
      return formatCPF(cleanDoc);
    } else if (cleanDoc.length == 14) {
      return formatCNPJ(cleanDoc);
    }

    return documento; // Retorna original se não for CPF nem CNPJ
  }

  /// Valida documento (CPF ou CNPJ baseado no tamanho)
  static bool isValidDocumento(String documento) {
    final cleanDoc = removeAllFormatting(documento);

    if (cleanDoc.length == 11) {
      return isValidCPF(cleanDoc);
    } else if (cleanDoc.length == 14) {
      return isValidCNPJ(cleanDoc);
    }

    return false;
  }
}
