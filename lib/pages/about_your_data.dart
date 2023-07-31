import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class AboutYourDataPage extends StatelessWidget {
  const AboutYourDataPage({super.key});

  List<Widget> _pages(BuildContext context) {
    return [
      buildPage(context, 'Your phone number is a must', 'We need your phone number to verify your identity and to keep your account secure.', null, 'https://i.redd.it/7sszbzxboor21.gif'),
      buildPage(context, 'But, is it safe?', 'We use the latest security technology to keep your authentication data safe.', null, 'https://i.pinimg.com/originals/ee/29/98/ee2998cdb1cf6a6bf66bf65fe0076fd2.gif'),
      buildPage(context, 'We encrypt your phone number', 'We encrypt your phone number and store it securely.', null, 'https://images.squarespace-cdn.com/content/v1/5941161b2e69cf3442450095/1595083939599-22FFDGXOH6L7BOWWUP27/loop-threads.gif'),
      buildPage(context, 'No one can see your phone number', 'No one can see your phone number, not even us, it\'s all encrypted.', null, 'https://cdn.dribbble.com/users/1518775/screenshots/6697986/fangers_loop_dribbble.gif'),
      buildPage(context, 'Your data is private', 'We don\'t share your data with anyone unless you tell us to.', null, null),
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
        title: Text('About your data'),
      ),
      body: PageView(
        children: _pages(context),
      ),
    );
  }
}
