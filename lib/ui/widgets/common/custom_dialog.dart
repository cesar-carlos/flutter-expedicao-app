import 'package:flutter/material.dart';

import 'package:data7_expedicao/core/utils/app_logger.dart';

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
      width: width,
      height: height,
      contentPadding: contentPadding ?? const EdgeInsets.all(24.0),
      actionsPadding: actionsPadding ?? const EdgeInsets.fromLTRB(24, 0, 24, 24),
      scrollable: scrollable,
      mainAxisSize: mainAxisSize,
    );
  }

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

    if (width != null || height != null) {
      contentWidget = SizedBox(width: width ?? double.infinity, height: height, child: contentWidget);
    } else {
      contentWidget = LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = MediaQuery.of(context).size.width;
          return SizedBox(width: screenWidth * 0.9, height: height, child: contentWidget);
        },
      );
    }

    return contentWidget;
  }
}

extension CustomDialogExtension on BuildContext {
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
      builder: (dialogContext) => CustomDialog.responsive(
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
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir CustomDialog.responsive',
        tag: 'CustomDialog',
        error: e,
        stackTrace: s,
      );
      return null;
    });
  }

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
      builder: (dialogContext) => CustomDialog.fixed(
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
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir CustomDialog.fixed',
        tag: 'CustomDialog',
        error: e,
        stackTrace: s,
      );
      return null;
    });
  }

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
      builder: (dialogContext) => CustomDialog.custom(
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
    ).catchError((Object e, StackTrace s) {
      AppLogger.warning(
        'Falha ao exibir CustomDialog.custom',
        tag: 'CustomDialog',
        error: e,
        stackTrace: s,
      );
      return null;
    });
  }
}
