import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Guard contra dessincronia entre os arquivos .arb de localizacao.
///
/// Background: na auditoria foi encontrado que `app_en_US.arb` tinha
/// 53 chaves a menos que `app_en.arb`, e `app_pt_BR.arb` tinha 1 chave
/// a menos que `app_pt.arb`. Isso causava chaves indisponiveis em
/// runtime ao usar locales especificos (en_US, pt_BR como template).
///
/// Estes testes garantem que adicionar uma chave em qualquer .arb
/// requer adicionar nos outros 3, prevenindo regressao.
void main() {
  Map<String, dynamic> readArb(String path) {
    final raw = File(path).readAsBytesSync();
    // Remove BOM se presente.
    final text = utf8.decode(raw, allowMalformed: false).replaceFirst('\uFEFF', '');
    return jsonDecode(text) as Map<String, dynamic>;
  }

  Set<String> publicKeys(Map<String, dynamic> arb) {
    return arb.keys.where((k) => !k.startsWith('@')).toSet();
  }

  late Map<String, dynamic> ptArb;
  late Map<String, dynamic> ptBrArb;
  late Map<String, dynamic> enArb;
  late Map<String, dynamic> enUsArb;

  setUpAll(() {
    ptArb = readArb('lib/l10n/app_pt.arb');
    ptBrArb = readArb('lib/l10n/app_pt_BR.arb');
    enArb = readArb('lib/l10n/app_en.arb');
    enUsArb = readArb('lib/l10n/app_en_US.arb');
  });

  group('ARB sync guard', () {
    test('todos os 4 .arb tem o mesmo conjunto de chaves', () {
      final ptKeys = publicKeys(ptArb);
      final ptBrKeys = publicKeys(ptBrArb);
      final enKeys = publicKeys(enArb);
      final enUsKeys = publicKeys(enUsArb);

      expect(
        ptKeys.difference(enKeys),
        isEmpty,
        reason: 'Chaves em app_pt.arb mas nao em app_en.arb',
      );
      expect(
        enKeys.difference(ptKeys),
        isEmpty,
        reason: 'Chaves em app_en.arb mas nao em app_pt.arb',
      );
      expect(
        ptKeys.difference(ptBrKeys),
        isEmpty,
        reason: 'Chaves em app_pt.arb mas nao em app_pt_BR.arb',
      );
      expect(
        enKeys.difference(enUsKeys),
        isEmpty,
        reason: 'Chaves em app_en.arb mas nao em app_en_US.arb',
      );
    });

    test('PT nao contem strings em ingles obvias', () {
      // Bug encontrado na auditoria: "loginSystem" estava com valor
      // "Login System" (ingles) no arquivo PT. Este teste detecta
      // strings PT que sao identicas a sua versao EN E que parecem
      // ser frase em ingles (contem palavras ingles).
      const englishOnlyWords = {
        'system', 'login', 'configuration', 'settings', 'register',
        'cancel', 'confirm', 'connection', 'failed', 'success',
      };

      final ptKeys = publicKeys(ptArb);
      final enKeys = publicKeys(enArb);
      final suspect = <String, String>{};
      for (final k in ptKeys.intersection(enKeys)) {
        final ptVal = ptArb[k] as String?;
        final enVal = enArb[k] as String?;
        if (ptVal == null || enVal == null) continue;
        if (ptVal != enVal) continue;
        // Tolera valores tecnicos curtos: URLs, hints, palavras
        // universais (Online, Offline, https, http).
        if (ptVal.length < 4) continue;
        if (RegExp(r'^[a-z0-9_/.:-]+$').hasMatch(ptVal)) continue; // url/protocolo/path

        // Detecta se contem palavra "puramente inglesa".
        final lower = ptVal.toLowerCase();
        if (englishOnlyWords.any((w) => RegExp('\\b$w\\b').hasMatch(lower))) {
          suspect[k] = ptVal;
        }
      }
      expect(
        suspect,
        isEmpty,
        reason: 'PT possui strings que parecem estar em ingles: $suspect',
      );
    });
  });
}
