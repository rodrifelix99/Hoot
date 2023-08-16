import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LastWelcomeScreen extends StatelessWidget {
  const LastWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: AppLocalizations.of(context)!.thatsIt,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      extendBodyBehindAppBar: true,
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                      'assets/images/image_19.png'
                  ),
                )
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                },
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                  foregroundColor: MaterialStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                ),
                child: Text(AppLocalizations.of(context)!.getStarted),
              ),
            )
          ],
        ),
      )
    );
  }
}
