import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';

class LastWelcomeScreen extends StatelessWidget {
  const LastWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'thatsIt'.tr,
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
                  Get.offAllNamed('/home', predicate: (route) => false);
                },
                style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
                  backgroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.onPrimary),
                  foregroundColor: WidgetStateProperty.all<Color>(Theme.of(context).colorScheme.primary),
                ),
                child: Text('getStarted'.tr),
              ),
            )
          ],
        ),
      )
    );
  }
}
