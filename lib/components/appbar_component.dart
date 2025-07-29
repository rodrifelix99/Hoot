import 'package:flutter/material.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevationDuringScroll;

  const AppBarComponent({
    super.key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevationDuringScroll,
});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      scrolledUnderElevation: elevationDuringScroll,
      shadowColor: Theme.of(context).colorScheme.surface.withValues(alpha: .25),
      title: title != null ? PreferredSize(
        preferredSize: preferredSize,
        child: Text(
          title!,
          overflow: TextOverflow.fade,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: foregroundColor ?? Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w900,
            fontSize: 32,
          ),
        ),
      ) : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}