import 'package:flutter/material.dart';
import 'package:hoot/services/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/error_service.dart';

class VerifyPage extends StatefulWidget {
  const VerifyPage({super.key});

  @override
  State<VerifyPage> createState() => _VerifyPageState();
}

class _VerifyPageState extends State<VerifyPage> {
  late AuthProvider _authProvider;
  final TextEditingController _codeController = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    try {
      _authProvider.verifyPhoneNumber();
    } catch (e) {
      setState(() {
        ToastService.showToast(context, e.toString(), true);
        Navigator.pop(context);
      });
    }
    super.initState();
  }

  Future _resentCode() async {
    try {
      await _authProvider.verifyPhoneNumber();
    } catch (e) {
      print(e.toString());
    }
  }

  Future _onSubmit() async {
    setState(() {
      _loading = true;
    });
    try {
      String code = await _authProvider.signInWithPhoneCredential(_codeController.text);
      switch (code) {
        case "success":
          setState(() {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          });
          break;
        case "new-user":
          setState(() {
            Navigator.of(context).pushNamedAndRemoveUntil('/welcome', (route) => false);
          });
          break;
        case "invalid-verification-code":
          setState(() {
            ToastService.showToast(context, AppLocalizations.of(context)!.invalidVerificationCode, true);
          });
          break;
        default:
          ToastService.showToast(context, code, true);
          break;
      }
    } catch (e) {
      print(e.toString());
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify your phone number'),
      ),
      body: _authProvider.verificationId == null || _loading ? const Center(
        child: CircularProgressIndicator(),
      ) : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'We sent a code to ${_authProvider.phoneNumber.phoneNumber}',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 26),
              AutofillGroup(
                child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Enter code',
                    ),
                    autofocus: true,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                    onSubmitted: (_) => _onSubmit(),
                    onChanged: (_) => {
                      if (_codeController.text.length == 6) {
                        _onSubmit(),
                      }
                    }),
              )
            ],
          ),
        ),
      ),
    );
  }
}
