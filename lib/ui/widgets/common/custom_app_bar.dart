import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:exp/ui/widgets/common/socket_widgets.dart';
import 'package:exp/domain/viewmodels/auth_viewmodel.dart';
import 'package:exp/core/utils/string_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showSocketStatus;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;
  final PreferredSizeWidget? bottom;
  final bool showUserInfo;
  final bool replaceWithUserName;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showSocketStatus = true,
    this.centerTitle = false,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
    this.bottom,
    this.showUserInfo = false,
    this.replaceWithUserName = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: replaceWithUserName ? _buildUserTitle(context) : _buildNormalTitle(),
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
      bottom: bottom,
      actions: [
        if (showSocketStatus) ...[
          const Center(
            child: SocketStatusIndicator(
              showLabel: true,
              size: 10,
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
          ),
          const SizedBox(width: 8),
        ],

        if ((actions?.isEmpty ?? true) && showSocketStatus) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNormalTitle() {
    return Text(title, style: foregroundColor != null ? TextStyle(color: foregroundColor) : null);
  }

  Widget _buildUserTitle(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final currentUser = authViewModel.currentUser;
        final userName = currentUser?.nome ?? title;
        return Text(
          'Olá ${StringUtils.capitalizeWords(userName)}',
          style: foregroundColor != null ? TextStyle(color: foregroundColor) : null,
        );
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));

  factory CustomAppBar.simple({required String title, bool showSocketStatus = true, Widget? leading}) {
    return CustomAppBar(title: title, showSocketStatus: showSocketStatus, leading: leading);
  }

  factory CustomAppBar.withActions({
    required String title,
    required List<Widget> actions,
    bool showSocketStatus = true,
    Widget? leading,
    bool centerTitle = false,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      showSocketStatus: showSocketStatus,
      leading: leading,
      centerTitle: centerTitle,
    );
  }

  factory CustomAppBar.withoutSocket({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool centerTitle = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      leading: leading,
      showSocketStatus: false,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }

  factory CustomAppBar.withUserInfo({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool showSocketStatus = true,
    bool replaceWithUserName = false,
    bool centerTitle = false,
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
  }) {
    return CustomAppBar(
      title: title,
      actions: actions,
      leading: leading,
      showSocketStatus: showSocketStatus,
      showUserInfo: true,
      replaceWithUserName: replaceWithUserName,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }
}
