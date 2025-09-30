import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/ui/widgets/common/index.dart';
import 'package:exp/ui/widgets/app_drawer/index.dart';
import 'package:exp/domain/viewmodels/home_viewmodel.dart';
import 'package:exp/ui/widgets/home/index.dart';
import 'package:exp/di/locator.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = locator<HomeViewModel>();
        viewModel.initialize();
        return viewModel;
      },
      child: Scaffold(
        appBar: CustomAppBar.withUserInfo(title: 'Data7 Expedição', replaceWithUserName: true, showSocketStatus: true),
        drawer: const AppDrawer(),
        body: Consumer<HomeViewModel>(
          builder: (context, homeViewModel, child) {
            if (homeViewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                // Header com boas-vindas
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        homeViewModel.welcomeMessage,
                        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(homeViewModel.subtitleMessage, style: const TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  ),
                ),
                // Grid de opções
                const Expanded(child: HomeMenuGrid()),
              ],
            );
          },
        ),
      ),
    );
  }
}
