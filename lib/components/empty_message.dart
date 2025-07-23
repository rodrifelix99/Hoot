import 'package:flutter/material.dart';

class NothingToShowComponent extends StatelessWidget {
  final Icon icon;
  final String text;
  final String? buttonText;
  final VoidCallback? buttonAction;
  const NothingToShowComponent({super.key, required this.icon, required this.text, this.buttonText, this.buttonAction});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon.icon,
            size: 100.0,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
          ),
          const SizedBox(height: 10.0),
          Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
            ),
          ),
          const SizedBox(height: 20.0),
          if (buttonText != null && buttonAction != null) ElevatedButton(
            onPressed: buttonAction,
            style: ElevatedButtonTheme.of(context).style?.copyWith(
              backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.secondaryContainer),
              foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onSecondaryContainer),
            ),
            child: Text(buttonText!),
          ),
        ],
      ),
    );
  }
}
