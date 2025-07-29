import 'package:flutter/cupertino.dart';

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
    return CupertinoNavigationBar(
      backgroundColor: backgroundColor,
      middle: title != null
          ? Text(
              title!,
              overflow: TextOverflow.fade,
              style: TextStyle(
                color:
                    foregroundColor ?? CupertinoTheme.of(context).primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: 32,
                fontFamily: 'Inter',
              ),
            )
          : null,
      trailing: actions != null
          ? Row(mainAxisSize: MainAxisSize.min, children: actions!)
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(44.0);
}