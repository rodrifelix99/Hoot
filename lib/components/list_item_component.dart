import 'package:flutter/material.dart';
import 'package:hoot/components/shimmer_skeletons.dart';

class ListItemComponent extends StatelessWidget {
  final Widget? leading;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool isLoading;
  final bool small;
  const ListItemComponent({super.key, this.leading, required this.title, required this.subtitle, this.trailing, this.backgroundColor, this.foregroundColor, this.isLoading = false, this.small = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      height: small ? 125 : 200,
      child: Stack(
        children: [
          Positioned(
            top: small ? 20 : 40,
            left: 0,
            right: 0,
            bottom: 0,
            child: ShimmerLoading(
              isLoading: isLoading,
              skeleton: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: backgroundColor ?? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: small ? Theme.of(context).textTheme.titleSmall!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: foregroundColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                      ) : Theme.of(context).textTheme.titleLarge!.copyWith(
                        color: foregroundColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.8)
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75)
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          leading != null ? Positioned(
            top: 0,
            left: 20,
            child: ShimmerLoading(
              isLoading: isLoading,
              skeleton: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x26000000),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: leading,
              ),
            ),
          ) : Container(),
          trailing != null ? Positioned(
            top: 50,
            right: 15,
            child: trailing!,
          ) : Container(),
        ]
      ),
    );
  }
}
