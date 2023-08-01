import 'package:flutter/material.dart';
import 'package:hoot/pages/about_your_data.dart';
import 'package:webview_flutter/webview_flutter.dart';

class TermsOfService extends StatefulWidget {
  const TermsOfService({super.key});

  @override
  State<TermsOfService> createState() => _TermsOfServiceState();
}

class _TermsOfServiceState extends State<TermsOfService> {
  late final WebViewController _controller;

  @override
  void initState() {
    _controller = WebViewController();
    _controller.loadFlutterAsset('assets/terms/terms.html');
    _controller.platform.enableZoom(true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Terms of Service & Privacy Policy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shield_rounded),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const AboutYourDataPage()));
            },
          ),
        ],

      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
