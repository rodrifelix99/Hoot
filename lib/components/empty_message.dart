import 'package:flutter/material.dart';

class NothingToShowComponent extends StatelessWidget {
  final Icon? icon;
  final String? imageAsset;
  final String? title;
  final String text;
  final String? buttonText;
  final VoidCallback? buttonAction;

  const NothingToShowComponent({
    super.key,
    this.icon,
    required this.text,
    this.buttonText,
    this.buttonAction,
    this.imageAsset,
    this.title,
  }) : assert(icon != null || imageAsset != null,
            'Either icon or imageAsset must be provided');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: 100.0,
              height: 100.0,
            )
          else if (icon != null)
            Icon(icon?.icon,
                size: 100.0,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          if (title != null) ...[
            const SizedBox(height: 10.0),
            Text(
              title!,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 10.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20.0),
          if (buttonText != null && buttonAction != null)
            ElevatedButton(
              onPressed: buttonAction,
              style: ElevatedButtonTheme.of(context).style?.copyWith(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.secondaryContainer),
                    foregroundColor: WidgetStateProperty.all<Color>(
                        Theme.of(context).colorScheme.onSecondaryContainer),
                  ),
              child: Text(buttonText!),
            ),
        ],
      ),
    );
  }
}
