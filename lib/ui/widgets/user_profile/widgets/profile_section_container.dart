import 'package:flutter/material.dart';

/// Container reutilizável para seções do perfil com gradiente e estilo consistente
/// Usado em UserInfoChips para manter consistência visual
class ProfileSectionContainer extends StatelessWidget {
  final Widget child;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final EdgeInsets? padding;
  final EdgeInsets? margin;

  const ProfileSectionContainer({
    super.key,
    required this.child,
    this.gradientColors,
    this.borderColor,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 16),
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradientColors != null
            ? LinearGradient(colors: gradientColors!, begin: Alignment.topLeft, end: Alignment.bottomRight)
            : null,
        color: gradientColors == null ? colorScheme.surface : null,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.08),
            offset: const Offset(0, 4),
            blurRadius: 12,
            spreadRadius: 0,
          ),
        ],
      ),
      child: child,
    );
  }
}

/// Variantes pré-definidas do ProfileSectionContainer
class PrimaryProfileSection extends StatelessWidget {
  final Widget child;

  const PrimaryProfileSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionContainer(
      gradientColors: [colorScheme.primaryContainer.withOpacity(0.3), colorScheme.primaryContainer.withOpacity(0.1)],
      borderColor: colorScheme.primary.withOpacity(0.2),
      child: child,
    );
  }
}

class SecondaryProfileSection extends StatelessWidget {
  final Widget child;

  const SecondaryProfileSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionContainer(
      gradientColors: [
        colorScheme.secondaryContainer.withOpacity(0.3),
        colorScheme.secondaryContainer.withOpacity(0.1),
      ],
      borderColor: colorScheme.secondary.withOpacity(0.2),
      child: child,
    );
  }
}

class TertiaryProfileSection extends StatelessWidget {
  final Widget child;

  const TertiaryProfileSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionContainer(
      gradientColors: [colorScheme.tertiaryContainer.withOpacity(0.3), colorScheme.tertiaryContainer.withOpacity(0.1)],
      borderColor: colorScheme.tertiary.withOpacity(0.2),
      child: child,
    );
  }
}

/// Container para seções de erro/aviso
class ErrorProfileSection extends StatelessWidget {
  final Widget child;

  const ErrorProfileSection({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ProfileSectionContainer(
      gradientColors: [colorScheme.errorContainer.withOpacity(0.1), colorScheme.surface],
      borderColor: colorScheme.error.withOpacity(0.3),
      child: child,
    );
  }
}
