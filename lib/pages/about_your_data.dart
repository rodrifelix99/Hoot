import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AboutYourDataPage extends StatelessWidget {
  const AboutYourDataPage({super.key});

  List<Widget> _pages(BuildContext context) {
    return [
      buildPage(context, AppLocalizations.of(context)!.aboutYourDataTitle1, AppLocalizations.of(context)!.aboutYourDataDescription1, null, 'https://i.redd.it/7sszbzxboor21.gif'),
      buildPage(context, AppLocalizations.of(context)!.aboutYourDataTitle2, AppLocalizations.of(context)!.aboutYourDataDescription2, null, 'https://i.pinimg.com/originals/ee/29/98/ee2998cdb1cf6a6bf66bf65fe0076fd2.gif'),
      buildPage(context, AppLocalizations.of(context)!.aboutYourDataTitle3, AppLocalizations.of(context)!.aboutYourDataDescription3, null, 'https://images.squarespace-cdn.com/content/v1/5941161b2e69cf3442450095/1595083939599-22FFDGXOH6L7BOWWUP27/loop-threads.gif'),
      buildPage(context, AppLocalizations.of(context)!.aboutYourDataTitle4, AppLocalizations.of(context)!.aboutYourDataDescription4, null, 'https://cdn.dribbble.com/users/1518775/screenshots/6697986/fangers_loop_dribbble.gif'),
      buildPage(context, AppLocalizations.of(context)!.aboutYourDataTitle5, AppLocalizations.of(context)!.aboutYourDataDescription5, null, null),
    ];
  }

  Widget buildPage(BuildContext context, String title, String text, String? image, String? backgroundImage) {
    return Stack(
      children: [
        Positioned.fill(
            child: OctoImage(
              image: NetworkImage(backgroundImage ?? 'https://i.pinimg.com/originals/7b/84/9b/7b849be9e09eb87ddaa2a732ab2c8034.gif'),
              fit: BoxFit.cover,
              placeholderBuilder: OctoPlaceholder.blurHash(
                'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
              ),
              errorBuilder: OctoError.icon(color: Colors.red),
            )
        ),
        image?.isNotEmpty ?? false ? Positioned(
          top: 50,
          left: 20,
          right: 20,
          bottom: 50,
          child: OctoImage(
            image: NetworkImage(image!),
            fit: BoxFit.contain,
            placeholderBuilder: OctoPlaceholder.blurHash(
              'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
            ),
            errorBuilder: OctoError.icon(color: Colors.red),
          ),
        ) : Container(),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: 50,
              top: 100,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                    text,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                      color: Colors.white,
                    ),
                ),
              ],
      ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(AppLocalizations.of(context)!.aboutYourData),
      ),
      body: PageView(
        children: _pages(context),
      ),
    );
  }
}
