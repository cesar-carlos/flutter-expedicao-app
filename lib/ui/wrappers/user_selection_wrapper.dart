import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/ui/screens/user_selection_screen.dart';

class UserSelectionWrapper extends StatefulWidget {
  const UserSelectionWrapper({super.key});

  @override
  State<UserSelectionWrapper> createState() => _UserSelectionWrapperState();
}

class _UserSelectionWrapperState extends State<UserSelectionWrapper> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authViewModel = context.read<AuthViewModel>();
      final userSelectionViewModel = context.read<UserSelectionViewModel>();

      if (authViewModel.currentUser != null) {
        userSelectionViewModel.initialize(authViewModel.currentUser!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final authViewModel = context.read<AuthViewModel>();
        authViewModel.cancelUserSelection();
      },
      child: const UserSelectionScreen(),
    );
  }
}
