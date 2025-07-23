import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/components/avatar_component.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:hoot/app/controllers/auth_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late U user;
  File? _profilePicture;
  File? _bannerPicture;
  bool _isLoading = false;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    user = Get.find<AuthController>().user!;
    _nameController.text = user.name ?? '';
    _usernameController.text = user.username ?? '';
    _bioController.text = user.bio ?? '';
    super.initState();
  }

  _isFormValid() {
    return _nameController.text.isNotEmpty && _bioController.text.length <= 150;
  }

  Future _pickProfilePicture() async {
    File? image = await _pickImage(CropAspectRatioPreset.square, 1, 1);
    setState(() => _profilePicture = image);
  }

  Future _pickBannerPicture() async {
    File? image = await _pickImage(CropAspectRatioPreset.original, 1, 1);
    setState(() => _bannerPicture = image);
  }

  Future<File> _pickImage(CropAspectRatioPreset preset, double ratioX, double ratioY) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path.isNotEmpty && pickedFile.path.length <= 1000000) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: CropAspectRatio(ratioX: ratioX, ratioY: ratioY),
        aspectRatioPresets: [preset],
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Crop avatar',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Crop avatar',
          ),
          WebUiSettings(
            context: context,
          ),
        ],
      );
      if (croppedImage != null) {
        return File(croppedImage.path);
      } else {
        return File(pickedFile.path);
      }
    } else if (pickedFile != null) {
      ToastService.showToast(context, 'imageTooLarge'.tr, true);
      return File('');
    } else {
      return File('');
    }
  }

  Future _updateProfile() async {
    if (_isFormValid()) {
      try {
        FocusScope.of(context).unfocus();
        setState(() => _isLoading = true);
        user.name = _nameController.text;
        user.bio = _bioController.text;

        if(_profilePicture != null) {
          user.smallProfilePictureUrl = await UploadService().uploadFile(_profilePicture!, 'avatars/${user.uid}/small', compressed: true, size: 100, square: true);
          user.largeProfilePictureUrl = await UploadService().uploadFile(_profilePicture!, 'avatars/${user.uid}/big', compressed: true, size: 250, square: true);
        }

        if (_bannerPicture != null) {
          user.bannerPictureUrl = await UploadService().uploadFile(_bannerPicture!, 'banners/${user.uid}', compressed: true, size: 1000, square: false);
        }

        bool res = await Get.find<AuthController>().updateUser(user);
        if (!res) {
          setState(() {
            _isLoading = false;
            ToastService.showToast(context, 'errorEditingProfile'.tr, true);
          });
        } else {
          Get.back();
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, 'errorEditingProfile'.tr, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('editProfile'.tr),
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
                'done'.tr,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        image: _bannerPicture == null ? user.bannerPictureUrl != null ? DecorationImage(
                          image: NetworkImage(user.bannerPictureUrl!),
                          fit: BoxFit.cover,
                        ) : null : DecorationImage(
                          image: FileImage(_bannerPicture!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: GestureDetector(
                        onTap: () => _pickBannerPicture(),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Icon(
                            SolarIconsOutline.galleryAdd,
                            color: Theme.of(context).colorScheme.onSurface,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: Stack(
                    children: [
                      _profilePicture == null ?
                      ProfileAvatarComponent(image: user.largeProfilePictureUrl ?? '', size: 150)
                          : CircleAvatar(
                        radius: 50,
                        backgroundImage: FileImage(_profilePicture!),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () => _pickProfilePicture(),
                          child: Container(
                            height: 30,
                            width: 30,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Icon(
                              SolarIconsOutline.galleryAdd,
                              color: Theme.of(context).colorScheme.onSurface,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        maxLength: 30,
                        decoration: InputDecoration(
                          labelText: 'displayName'.tr,
                          counter: const SizedBox(),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _usernameController,
                        maxLength: 15,
                        decoration: InputDecoration(
                          labelText: 'username'.tr,
                          counter: const SizedBox(),
                          enabled: false,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        maxLength: 150,
                        decoration: InputDecoration(
                          labelText: 'bio'.tr,
                          alignLabelWithHint: true,
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        )
    );
  }
}
