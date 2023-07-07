import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoot/components/avatar.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../services/auth_provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late U user;
  File? _selectedImage;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    user = Provider.of<AuthProvider>(context, listen: false).user!;
    _nameController.text = user.name ?? '';
    _usernameController.text = user.username ?? '';
    _bioController.text = user.bio ?? '';
    super.initState();
  }

  _isFormValid() {
    return _nameController.text.isNotEmpty && _bioController.text.length <= 150;
  }

  void _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path.isNotEmpty && pickedFile.path.length <= 1000000) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    } else if (pickedFile != null) {
      ToastService.showToast(context, AppLocalizations.of(context)!.imageTooLarge, true);
    }
  }

  Future _updateProfile() async {
    if (_isFormValid()) {
      try {
        FocusScope.of(context).unfocus();
        setState(() => _isLoading = true);
        user.name = _nameController.text;
        user.bio = _bioController.text;

        if(_selectedImage != null) {
          user.smallProfilePictureUrl = await UploadService().uploadFile(_selectedImage!, 'avatars/${user.uid}/small', compressed: true, size: 50);
          user.largeProfilePictureUrl = await UploadService().uploadFile(_selectedImage!, 'avatars/${user.uid}/big', compressed: true);
        }

        bool res = await Provider.of<AuthProvider>(context, listen: false).updateUser(user);
        if (!res) {
          setState(() {
            _isLoading = false;
            ToastService.showToast(context, AppLocalizations.of(context)!.errorEditingProfile, true);
          });
        } else {
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, AppLocalizations.of(context)!.errorEditingProfile, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.editProfile),
          actions: [
            _isLoading ? const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator()
              ),
            ) :
            TextButton(
              onPressed: _updateProfile,
              child: Text(
                AppLocalizations.of(context)!.done,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Center(
                child: Stack(
                  children: [
                    _selectedImage == null ?
                    ProfileAvatar(image: user.largeProfilePictureUrl ?? '', size: 100)
                        : CircleAvatar(
                      radius: 50,
                      backgroundImage: FileImage(_selectedImage!),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.displayName,
                        counter: const SizedBox(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _usernameController,
                      maxLength: 15,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.username,
                        counter: const SizedBox(),
                        enabled: false,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _bioController,
                      maxLines: 3,
                      maxLength: 150,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.bio,
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Text(
                      'Please note that this options are just for testing purposes.\n'
                      'Hoot profiles will be completely customizable in the future. Here are some examples of what you will be able to do:\n'
                      '- Choose a background image for your profile\n'
                      '- Choose a color for your profile\n'
                      '- Choose your anthem song from Spotify\n'
                      '- Add a frame to your profile picture\n'
                      '- Etc...',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        )
    );
  }
}
