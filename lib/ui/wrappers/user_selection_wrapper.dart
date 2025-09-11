import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/domain/viewmodels/user_selection_viewmodel.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/ui/screens/user_selection_screen.dart';

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
    return WillPopScope(
      onWillPop: () async {
        final authViewModel = context.read<AuthViewModel>();
        authViewModel.cancelUserSelection();
        return true;
      },
      child: const UserSelectionScreen(),
    );
  }
}
