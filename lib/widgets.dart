import 'package:flutter/material.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.color,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final r = BorderRadius.circular(22);
    return Material(
      color: color ?? cs.surface,
      borderRadius: r,
      child: InkWell(
        borderRadius: r,
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: r,
            border: Border.all(color: cs.outline.withOpacity(.18)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// ظهور تدريجي مع انزلاق خفيف. كلما زاد index تأخر الظهور قليلاً.
class FadeSlide extends StatelessWidget {
  const FadeSlide({super.key, required this.child, this.index = 0});
  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index.clamp(0, 8) * 90),
      curve: Curves.easeOutCubic,
      builder: (c, v, w) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 24 * (1 - v)), child: w),
      ),
      child: child,
    );
  }
}

Route<T> slideRoute<T>(Widget page) => PageRouteBuilder<T>(
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, anim, __, child) {
        final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
                    begin: const Offset(0, .06), end: Offset.zero)
                .animate(curved),
            child: child,
          ),
        );
      },
    );

class PageTitle extends StatelessWidget {
  const PageTitle(this.title, {super.key});
  final String title;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Text(title,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.w800)),
      );
}
