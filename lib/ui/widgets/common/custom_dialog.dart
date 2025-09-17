import 'package:flutter/material.dart';

/// Widget personalizado para diálogos com largura customizável
class CustomDialog extends StatelessWidget {
  final String title;
  final Widget? titleIcon;
  final Widget content;
  final List<Widget>? actions;
  final double? width;
  final double? height;
  final EdgeInsets? contentPadding;
  final EdgeInsets? actionsPadding;
  final bool scrollable;
  final MainAxisSize mainAxisSize;

  const CustomDialog({
    super.key,
    required this.title,
    this.titleIcon,
    required this.content,
    this.actions,
    this.width,
    this.height,
    this.contentPadding,
    this.actionsPadding,
    this.scrollable = true,
    this.mainAxisSize = MainAxisSize.min,
  });

  /// Cria um diálogo com largura responsiva (80% da tela)
  factory CustomDialog.responsive({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double? width,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return CustomDialog(
      title: title,
      titleIcon: titleIcon,
      content: content,
      actions: actions,
      width: width, // Se null, será calculado como 80% da tela
      height: height,
      contentPadding: contentPadding ?? const EdgeInsets.all(24.0),
      actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
      scrollable: scrollable,
      mainAxisSize: mainAxisSize,
    );
  }

  /// Cria um diálogo com largura fixa
  factory CustomDialog.fixed({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double width = 600,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return CustomDialog(
      title: title,
      titleIcon: titleIcon,
      content: content,
      actions: actions,
      width: width,
      height: height,
      contentPadding: contentPadding ?? const EdgeInsets.all(24.0),
      actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
      scrollable: scrollable,
      mainAxisSize: mainAxisSize,
    );
  }

  /// Cria um diálogo com largura e altura customizáveis
  factory CustomDialog.custom({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double? width,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
  }) {
    return CustomDialog(
      title: title,
      titleIcon: titleIcon,
      content: content,
      actions: actions,
      width: width,
      height: height,
      contentPadding: contentPadding ?? const EdgeInsets.all(24.0),
      actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
      scrollable: scrollable,
      mainAxisSize: mainAxisSize,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          if (titleIcon != null) ...[titleIcon!, const SizedBox(width: 8)],
          Expanded(
            child: Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      contentPadding: contentPadding,
      actionsPadding: actionsPadding,
      content: _buildContent(context),
      actions: actions,
    );
  }

  Widget _buildContent(BuildContext context) {
    Widget contentWidget = content;

    if (scrollable) {
      contentWidget = SingleChildScrollView(child: content);
    }

    // Se width ou height foram especificados, usar SizedBox
    if (width != null || height != null) {
      contentWidget = SizedBox(
        width: width ?? double.infinity, // Se width for null, usar largura máxima
        height: height,
        child: contentWidget,
      );
    } else {
      // Largura responsiva (80% da tela) quando width não especificado
      contentWidget = SizedBox(width: MediaQuery.of(context).size.width * 0.9, height: height, child: contentWidget);
    }

    return contentWidget;
  }
}

/// Extensão para facilitar o uso do CustomDialog
extension CustomDialogExtension on BuildContext {
  /// Mostra um CustomDialog responsivo
  Future<T?> showCustomDialog<T>({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double? width,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog.responsive(
        title: title,
        titleIcon: titleIcon,
        content: content,
        actions: actions,
        width: width,
        height: height,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        scrollable: scrollable,
        mainAxisSize: mainAxisSize,
      ),
    );
  }

  /// Mostra um CustomDialog com largura fixa
  Future<T?> showCustomDialogFixed<T>({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double width = 600,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog.fixed(
        title: title,
        titleIcon: titleIcon,
        content: content,
        actions: actions,
        width: width,
        height: height,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        scrollable: scrollable,
        mainAxisSize: mainAxisSize,
      ),
    );
  }

  /// Mostra um CustomDialog com largura e altura customizáveis
  Future<T?> showCustomDialogCustom<T>({
    required String title,
    Widget? titleIcon,
    required Widget content,
    List<Widget>? actions,
    double? width,
    double? height,
    EdgeInsets? contentPadding,
    EdgeInsets? actionsPadding,
    bool scrollable = true,
    MainAxisSize mainAxisSize = MainAxisSize.min,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: this,
      barrierDismissible: barrierDismissible,
      builder: (context) => CustomDialog.custom(
        title: title,
        titleIcon: titleIcon,
        content: content,
        actions: actions,
        width: width,
        height: height,
        contentPadding: contentPadding,
        actionsPadding: actionsPadding,
        scrollable: scrollable,
        mainAxisSize: mainAxisSize,
      ),
    );
  }
}
