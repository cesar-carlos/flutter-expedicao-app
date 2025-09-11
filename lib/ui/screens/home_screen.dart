import 'package:flutter/material.dart';

import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/ui/widgets/app_drawer/index.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar.withUserInfo(
        title: 'Data7 Expedição',
        replaceWithUserName: true,
        showSocketStatus: true,
      ),
      drawer: const AppDrawer(),
      body: Placeholder(),
    );
  }
}
