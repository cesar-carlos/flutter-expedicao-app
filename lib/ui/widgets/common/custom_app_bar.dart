import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:data7_expedicao/ui/widgets/common/socket_widgets.dart';
import 'package:data7_expedicao/domain/viewmodels/auth_viewmodel.dart';
import 'package:data7_expedicao/core/utils/string_utils.dart';
import 'package:data7_expedicao/core/theme/app_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// Aceita `String` ou `Widget` (validado em runtime).
  ///
  /// Bug latente anterior: era declarado como `dynamic` — silenciava
  /// type errors em compile time. Se um caller passasse `int`, `Map`
  /// etc, o cast em `_buildNormalTitle` crashava com TypeError em
  /// runtime sem warning de analyzer. Mudado para `Object` (mais
  /// restrito que `dynamic`) mantendo flexibilidade String|Widget.
  final Object title;
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

    final effectiveBackgroundColor = backgroundColor ?? theme.appBarTheme.backgroundColor ?? theme.colorScheme.primary;
    final effectiveForegroundColor =
        foregroundColor ?? theme.appBarTheme.foregroundColor ?? theme.colorScheme.onPrimary;

    return AppBar(
      title: replaceWithUserName
          ? _buildUserTitle(context, effectiveForegroundColor)
          : _buildNormalTitle(effectiveForegroundColor),
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

        if (actions != null) ...actions!,

        if ((actions?.isEmpty ?? true) && showSocketStatus) const SizedBox(width: 8),
      ],
    );
  }

  /// Bug visual anterior: usava `foregroundColor` cru (que e null em
  /// 90% dos calls). Resultado: o `AppBar` aplicava
  /// `effectiveForegroundColor` (com fallback para
  /// `theme.colorScheme.onPrimary`) ao topo, mas o titulo via `Text`
  /// usava `AppFonts.inter(color: null)` — Text caia para a cor
  /// default do `TextStyle` (preto/branco do tema), que podia
  /// CONTRASTAR com a cor do AppBar (ex.: titulo preto sobre AppBar
  /// teal). Agora usa o `effectiveForegroundColor` calculado para o
  /// AppBar, garantindo consistencia visual.
  Widget _buildNormalTitle(Color effectiveForegroundColor) {
    final t = title;
    if (t is Widget) {
      return t;
    }
    if (t is String) {
      return Text(t, style: AppFonts.inter(color: effectiveForegroundColor));
    }
    // Fallback defensivo: Object inesperado (ex.: caller passou int).
    return Text(t.toString(), style: AppFonts.inter(color: effectiveForegroundColor));
  }

  Widget _buildUserTitle(BuildContext context, Color effectiveForegroundColor) {
    return Consumer<AuthViewModel>(
      builder: (context, authViewModel, child) {
        final currentUser = authViewModel.currentUser;
        final fallback = title is String ? title as String : 'Usuário';
        final userName = currentUser?.nome ?? fallback;
        return Text(
          'Olá ${StringUtils.capitalizeWords(userName)}',
          style: AppFonts.inter(color: effectiveForegroundColor),
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
