import 'package:flutter/material.dart';
import 'package:exp/core/utils/fields_helper.dart';

/// Exemplo de uso do BrasilFieldsHelper
class BrasilFieldsExample extends StatefulWidget {
  const BrasilFieldsExample({super.key});

  @override
  State<BrasilFieldsExample> createState() => _BrasilFieldsExampleState();
}

class _BrasilFieldsExampleState extends State<BrasilFieldsExample> {
  final TextEditingController _cpfController = TextEditingController();
  final TextEditingController _cnpjController = TextEditingController();
  final TextEditingController _cepController = TextEditingController();
  final TextEditingController _telefoneController = TextEditingController();
  final TextEditingController _moedaController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brasil Fields - Exemplos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle('Formatação de Documentos'),
            _buildTextField(
              controller: _cpfController,
              label: 'CPF',
              hint: 'Digite o CPF',
              onChanged: (value) {
                final formatted = FieldsHelper.formatCPF(value);
                if (formatted != value) {
                  _cpfController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FieldsHelper.isValidCPF(value) ? null : 'CPF inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _cnpjController,
              label: 'CNPJ',
              hint: 'Digite o CNPJ',
              onChanged: (value) {
                final formatted = FieldsHelper.formatCNPJ(value);
                if (formatted != value) {
                  _cnpjController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FieldsHelper.isValidCNPJ(value)
                      ? null
                      : 'CNPJ inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Formatação de Contato'),
            _buildTextField(
              controller: _cepController,
              label: 'CEP',
              hint: 'Digite o CEP',
              onChanged: (value) {
                final formatted = FieldsHelper.formatCEP(value);
                if (formatted != value) {
                  _cepController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FieldsHelper.isValidCEP(value) ? null : 'CEP inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _telefoneController,
              label: 'Telefone',
              hint: 'Digite o telefone',
              onChanged: (value) {
                final formatted = FieldsHelper.formatTelefone(value);
                if (formatted != value) {
                  _telefoneController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  return FieldsHelper.isValidTelefone(value)
                      ? null
                      : 'Telefone inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Formatação de Valores'),
            _buildTextField(
              controller: _moedaController,
              label: 'Valor',
              hint: 'Digite o valor',
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final formatted = FieldsHelper.formatMoedaWithMask(value);
                if (formatted != value) {
                  _moedaController.value = TextEditingValue(
                    text: formatted,
                    selection: TextSelection.collapsed(
                      offset: formatted.length,
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Exemplos de Conversão'),
            _buildConversionExamples(),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _showFormattedData,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Ver Dados Formatados'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    Function(String)? onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.edit),
      ),
    );
  }

  Widget _buildConversionExamples() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildConversionItem(
              'CPF sem formatação:',
              '12345678901',
              FieldsHelper.formatCPF('12345678901'),
            ),
            const SizedBox(height: 8),
            _buildConversionItem(
              'CNPJ sem formatação:',
              '12345678000195',
              FieldsHelper.formatCNPJ('12345678000195'),
            ),
            const SizedBox(height: 8),
            _buildConversionItem(
              'CEP sem formatação:',
              '12345678',
              FieldsHelper.formatCEP('12345678'),
            ),
            const SizedBox(height: 8),
            _buildConversionItem(
              'Telefone sem formatação:',
              '11987654321',
              FieldsHelper.formatTelefone('11987654321'),
            ),
            const SizedBox(height: 8),
            _buildConversionItem(
              'Moeda:',
              '1234.56',
              FieldsHelper.formatMoeda(1234.56),
            ),
            const SizedBox(height: 8),
            _buildConversionItem(
              'Data brasileira:',
              'DateTime.now()',
              FieldsHelper.formatDataBrasileira(DateTime.now()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversionItem(String label, String input, String output) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text('Entrada: $input', style: const TextStyle(color: Colors.grey)),
        Text('Saída: $output', style: const TextStyle(color: Colors.green)),
      ],
    );
  }

  void _showFormattedData() {
    final cpf = FieldsHelper.removeCPFFormatting(_cpfController.text);
    final cnpj = FieldsHelper.removeCNPJFormatting(_cnpjController.text);
    final cep = FieldsHelper.removeCEPFormatting(_cepController.text);
    final telefone = FieldsHelper.removeTelefoneFormatting(
      _telefoneController.text,
    );
    final moeda = FieldsHelper.parseMoedaToDouble(_moedaController.text);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Dados Formatados'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDataItem('CPF (sem formatação):', cpf),
              _buildDataItem('CNPJ (sem formatação):', cnpj),
              _buildDataItem('CEP (sem formatação):', cep),
              _buildDataItem('Telefone (sem formatação):', telefone),
              _buildDataItem('Valor (double):', moeda.toString()),
              const SizedBox(height: 16),
              const Text(
                'Validações:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildValidationItem('CPF válido:', FieldsHelper.isValidCPF(cpf)),
              _buildValidationItem(
                'CNPJ válido:',
                FieldsHelper.isValidCNPJ(cnpj),
              ),
              _buildValidationItem('CEP válido:', FieldsHelper.isValidCEP(cep)),
              _buildValidationItem(
                'Telefone válido:',
                FieldsHelper.isValidTelefone(telefone),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '(vazio)' : value,
              style: TextStyle(
                color: value.isEmpty ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidationItem(String label, bool isValid) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Icon(
            isValid ? Icons.check_circle : Icons.cancel,
            color: isValid ? Colors.green : Colors.red,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            isValid ? 'Válido' : 'Inválido',
            style: TextStyle(
              color: isValid ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cpfController.dispose();
    _cnpjController.dispose();
    _cepController.dispose();
    _telefoneController.dispose();
    _moedaController.dispose();
    super.dispose();
  }
}
