import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/ui/widgets/common/socket_widgets.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/core/utils/string_utils.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final dynamic title; // Aceita String ou Widget
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
    final theme = Theme.of(context);
    final isDarkTheme = theme.brightness == Brightness.dark;

    // Se não foi especificada cor de fundo, usa preto no tema escuro ou cor primária no tema claro
    final effectiveBackgroundColor = backgroundColor ?? (isDarkTheme ? Colors.black : theme.colorScheme.primary);
    final effectiveForegroundColor = foregroundColor ?? (isDarkTheme ? Colors.white : theme.colorScheme.onPrimary);

    return AppBar(
      title: replaceWithUserName ? _buildUserTitle(context) : _buildNormalTitle(),
      leading: leading,
      centerTitle: centerTitle,
      backgroundColor: effectiveBackgroundColor,
      foregroundColor: effectiveForegroundColor,
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

        // Inclui os actions passados como parâmetro
        if (actions != null) ...actions!,

        if ((actions?.isEmpty ?? true) && showSocketStatus) const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildNormalTitle() {
    if (title is Widget) {
      return title as Widget;
    } else {
      return Text(title as String, style: foregroundColor != null ? TextStyle(color: foregroundColor) : null);
    }
  }

  Widget _buildUserTitle(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final currentUser = authViewModel.currentUser;
        final userName = currentUser?.nome ?? (title is String ? title as String : 'Usuário');
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

  /// Factory para criar AppBar com título customizado (Widget)
  factory CustomAppBar.withCustomTitle({
    required Widget title,
    List<Widget>? actions,
    Widget? leading,
    bool showSocketStatus = true,
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
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      elevation: elevation,
    );
  }
}
