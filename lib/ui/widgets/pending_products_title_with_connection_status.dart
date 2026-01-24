import 'package:flutter/material.dart';

import 'package:data7_expedicao/ui/widgets/common/title_with_connection_status.dart';

class PendingProductsTitleWithConnectionStatus extends StatelessWidget {
  const PendingProductsTitleWithConnectionStatus({super.key});

  @override
  Widget build(BuildContext context) {
    return const TitleWithConnectionStatus(title: 'Produtos Pendentes');
  }
}
