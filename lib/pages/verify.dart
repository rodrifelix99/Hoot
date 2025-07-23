import 'package:hoot/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/app/controllers/auth_controller.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/error_service.dart';
import '../app/utils/logger.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  late AuthController _authProvider;
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    _authProvider = Get.find<AuthController>();
    try {
      _authProvider.verifyPhoneNumber();
    } catch (e) {
      setState(() {
        ToastService.showToast(context, e.toString(), true);
        Get.back();
      });
    }
    super.initState();
  }

  Future _resentCode() async {
    try {
      await _authProvider.verifyPhoneNumber();
    } catch (e) {
      logError(e.toString());
    }
  }

  Future _onSubmit() async {
    setState(() {
      _loading = true;
    });
    try {
      String code =
          await _authProvider.signInWithPhoneCredential(_codeController.text);
      switch (code) {
        case "success":
          setState(() {
            Get.offAllNamed('/home', (route) => false);
          });
          break;
        case "new-user":
          setState(() {
            Get.offAllNamed('/welcome', (route) => false);
          });
          break;
        case "invalid-verification-code":
          setState(() {
            ToastService.showToast(context,
                AppLocalizations.of(context)!.invalidVerificationCode, true);
          });
          break;
        default:
          ToastService.showToast(context, code, true);
          break;
      }
    } catch (e) {
      logError(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarComponent(),
      body: _authProvider.verificationId == null || _loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Text(
                      AppLocalizations.of(context)!.verificationCode,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      AppLocalizations.of(context)!.codeSent(
                          _authProvider.phoneNumber.phoneNumber.toString()),
                    ),
                    const SizedBox(height: 50),
                    AutofillGroup(
                      child: TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            hintText: AppLocalizations.of(context)!.enterCode,
                          ),
                          autofocus: true,
                          autofillHints: const [AutofillHints.oneTimeCode],
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineSmall,
                          onSubmitted: (_) => _onSubmit(),
                          onChanged: (_) => {
                                if (_codeController.text.length == 6)
                                  {
                                    _onSubmit(),
                                  }
                              }),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.25),
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                      child: Text(AppLocalizations.of(context)!.changeNumber),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
