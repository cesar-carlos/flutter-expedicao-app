import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/theme/app_fonts.dart';

class ConsultationDetailItem extends StatelessWidget {
  const ConsultationDetailItem({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: AppFonts.inter(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value.isEmpty ? 'N/A' : value)),
        ],
      ),
    );
  }
}
