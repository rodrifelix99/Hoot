import 'package:flutter/material.dart';

class AppBarComponent extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevationDuringScroll;

  const AppBarComponent({
    Key? key,
    this.title,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.elevationDuringScroll,
}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      scrolledUnderElevation: elevationDuringScroll,
      shadowColor: Theme.of(context).colorScheme.background.withOpacity(.25),
      title: title != null ? PreferredSize(
        preferredSize: preferredSize,
        child: Text(
          title!,
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            color: Theme.of(context).colorScheme.primary,
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