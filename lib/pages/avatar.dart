import "dart:io";
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import '../app/controllers/auth_controller.dart';
import '../util/routes/app_routes.dart';

class AvatarPage extends StatefulWidget {
  const AvatarPage({super.key});

  @override
  State<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends State<AvatarPage> {
  XFile? _image;
  bool _loading = false;

  Future<void> _pick() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _image = picked);
    }
  }

  Future<void> _finish() async {
    setState(() => _loading = true);
    final auth = Get.find<AuthController>();
    final user = auth.user ?? U(uid: '');
    // In a real app you'd upload the file and get a URL.
    if (_image != null) {
      user.smallProfilePictureUrl = _image!.path;
      user.largeProfilePictureUrl = _image!.path;
    }
    await auth.updateUser(user);
    setState(() => _loading = false);
    if (mounted) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('almostThere'.tr)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('profilePictureDescription'.tr),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pick,
              child: _image == null
                  ? Container(
                      height: 120,
                      width: 120,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      child: const Icon(Icons.person),
                    )
                  : Image.file(
                      File(_image!.path),
                      height: 120,
                      width: 120,
                      fit: BoxFit.cover,
                    ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loading ? null : _finish,
              child: _loading
                  ? const CircularProgressIndicator.adaptive()
                  : Text('continueButton'.tr),
            ),
            TextButton(
              onPressed: _loading ? null : _finish,
              child: Text('skipForNow'.tr),
            ),
          ],
        ),
      ),
    );
  }
}
