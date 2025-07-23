import 'dart:io';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/pages/contacts.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octo_image/octo_image.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';

import 'package:hoot/app/controllers/auth_controller.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  SwiperController controller = SwiperController();
  late List<Widget> screens;
  List<String> images = [
    "https://images.pexels.com/photos/1934846/pexels-photo-1934846.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/2414036/pexels-photo-2414036.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/2693212/pexels-photo-2693212.png?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1",
    "https://images.pexels.com/photos/2894260/pexels-photo-2894260.jpeg?auto=compress&cs=tinysrgb&w=1260&h=750&dpr=1"
  ];

  @override
  void initState() {
    screens = [
      FirstScreen(controller: controller),
      SecondScreen(controller: controller),
      ThirdScreen(controller: controller)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              "assets/images/welcome_bg.png",
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/image_1.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_2.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_3.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_4.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_17.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_18.png",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(height: 50),
                      Image.asset(
                        "assets/images/image_5.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_6.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_7.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_8.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_15.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_16.png",
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        "assets/images/image_9.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_10.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_11.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_12.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_13.png",
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        "assets/images/image_14.png",
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.15),
                    spreadRadius: 2,
                    blurRadius: 20,
                    offset: const Offset(0, -5), // changes position of shadow
                  ),
                ],
              ),
              child: SafeArea(
                child: Swiper(
                  controller: controller,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (BuildContext context, int index) {
                    return screens[index];
                  },
                  itemCount: screens.length,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class FirstScreen extends StatefulWidget {
  final SwiperController controller;
  const FirstScreen({super.key, required this.controller});

  @override
  State<FirstScreen> createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  final TextEditingController _nameController = TextEditingController();

  bool _isNameValid() {
    return _nameController.text.isNotEmpty &&
        _nameController.text.length > 2 &&
        _nameController.text.length < 30;
  }

  Future _onSubmit() async {
    if (_isNameValid() && _nameController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      U? user = Get.find<AuthController>().user;
      if (user != null) {
        user.name = _nameController.text;
        widget.controller.next();
        bool response = await Get.find<AuthController>().updateUser(user);
        if (!response) {
          widget.controller.move(1, animation: true);
          setState(() {
            ToastService.showToast(
                context, 'errorUnknown'.tr, true);
          });
        }
      } else {
        FirebaseCrashlytics.instance.log('User is null');
        setState(() {
          ToastService.showToast(
              context, 'errorUnknown'.tr, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'waitANewFriend'.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'displayNameDescription'.tr,
        ),
        const SizedBox(height: 25),
        TextField(
          controller: _nameController,
          autocorrect: true,
          keyboardType: TextInputType.name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 30,
          onChanged: (value) => setState(() {}),
          onSubmitted: (value) => _onSubmit(),
          decoration: InputDecoration(
            labelText: 'displayName'.tr,
            counter: const SizedBox(),
          ),
        ),
        const SizedBox(height: 5),
        _isNameValid() || _nameController.text.isEmpty
            ? Text(
                'displayNameExample'.tr,
                style: Theme.of(context).textTheme.bodySmall,
              )
            : Text(
                'displayNameTooShort'.tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.red,
                    ),
              ),
        const Spacer(),
        ElevatedButton(
          onPressed: _isNameValid() ? _onSubmit : null,
          child: Text(
            'next'.tr,
          ),
        ),
      ],
    );
  }
}

class SecondScreen extends StatefulWidget {
  final SwiperController controller;
  const SecondScreen({super.key, required this.controller});

  @override
  State<SecondScreen> createState() => _SecondScreenState();
}

class _SecondScreenState extends State<SecondScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;

  bool _isValid() {
    return _usernameController.text.isNotEmpty &&
        _usernameController.text.length >= 6 &&
        _usernameController.text.length <= 15 &&
        RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(_usernameController.text);
  }

  Future _onSubmit() async {
    if (_isValid()) {
      setState(() {
        _loading = true;
      });
      if (await Get.find<AuthController>()
          .isUsernameAvailable(_usernameController.text)) {
        FocusScope.of(context).unfocus();
        U? user = Get.find<AuthController>().user;
        if (user != null) {
          user.username = _usernameController.text;
          setState(() {
            _loading = false;
          });
          widget.controller.next();
          bool response = await Get.find<AuthController>().updateUser(user);
          if (!response) {
            widget.controller.move(2, animation: true);
            setState(() {
              ToastService.showToast(
                  context, 'errorUnknown'.tr, true);
            });
          }
        } else {
          FirebaseCrashlytics.instance.log('User is null');
          setState(() {
            _loading = false;
            ToastService.showToast(context,
                'somethingWentWrong'.tr, true);
          });
        }
      } else {
        setState(() {
          _loading = false;
          ToastService.showToast(
              context, 'usernameTaken'.tr, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => widget.controller.previous(),
              icon: const Icon(SolarIconsOutline.arrowLeft),
            ),
            Text(
              'letsSpiceItUp'.tr,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'usernameDescription'.tr,
        ),
        const SizedBox(height: 25),
        _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLength: 15,
                onChanged: (value) => setState(() =>
                    _usernameController.text.contains("@")
                        ? _usernameController.text =
                            _usernameController.text.replaceAll("@", "")
                        : null),
                onSubmitted: (value) => _onSubmit(),
                decoration: InputDecoration(
                  labelText: 'username'.tr,
                  counter: const SizedBox(),
                ),
              ),
        const SizedBox(height: 5),
        _isValid() || _usernameController.text.isEmpty
            ? Text(
                'usernameExample'.tr,
                style: const TextStyle(
                  fontSize: 12,
                ),
              )
            : Text(
                'usernameInvalid'.tr,
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.red,
                    ),
              ),
        const Spacer(),
        ElevatedButton(
          onPressed: _isValid() ? _onSubmit : null,
          child: Text(
            'next'.tr,
          ),
        ),
      ],
    );
  }
}

class ThirdScreen extends StatefulWidget {
  final SwiperController controller;
  const ThirdScreen({super.key, required this.controller});

  @override
  State<ThirdScreen> createState() => _ThirdScreenState();
}

class _ThirdScreenState extends State<ThirdScreen> {
  bool _loading = false;
  File? _selectedImage;

  void _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path.isNotEmpty) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
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
      setState(() {
        _selectedImage = croppedImage == null ? null : File(croppedImage.path);
      });
    } else if (pickedFile != null) {
      ToastService.showToast(
          context, 'imageTooLarge'.tr, true);
    }
  }

  Future _uploadImage() async {
    if (_selectedImage != null && _selectedImage!.lengthSync() <= 1000000) {
      setState(() {
        _loading = true;
      });

      String uid = Get.find<AuthController>().user!.uid;
      String smallAvatarUrl = await UploadService().uploadFile(
          _selectedImage!, 'avatars/$uid/small',
          compressed: true, size: 100, square: true);
      String bigAvatarUrl = await UploadService().uploadFile(
          _selectedImage!, 'avatars/$uid/big',
          compressed: true, size: 250, square: true);

      if (smallAvatarUrl.isNotEmpty && bigAvatarUrl.isNotEmpty) {
        U? user = Get.find<AuthController>().user;
        if (user != null) {
          user.smallProfilePictureUrl = smallAvatarUrl;
          user.largeProfilePictureUrl = bigAvatarUrl;
          bool response = await Get.find<AuthController>().updateUser(user);
          if (response) {
            _goHome();
          } else {
            setState(() {
              ToastService.showToast(
                  context, 'errorUnknown'.tr, true);
            });
          }
        } else {
          FirebaseCrashlytics.instance.log('User is null');
        }
      } else {
        setState(() {
          ToastService.showToast(
              context, 'errorUnknown'.tr, true);
        });
      }
      setState(() {
        _loading = false;
      });
    } else if (_selectedImage != null) {
      ToastService.showToast(
          context, 'imageTooLarge'.tr, true);
    }
  }

  String _getRandomSuccessPhrase() {
    int random = Random().nextInt(3) + 1;
    switch (random) {
      case 1:
        return 'avatarSelectedFunny1'.tr;
      case 2:
        return 'avatarSelectedFunny2'.tr;
      case 3:
        return 'avatarSelectedFunny3'.tr;
      default:
        return 'avatarSelectedFunny1'.tr;
    }
  }

  void _goHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          builder: (context) => const ContactsPage(skipable: true)),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          'almostThere'.tr,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w900,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedImage == null
              ? 'profilePictureDescription'.tr
              : _getRandomSuccessPhrase(),
        ),
        const Spacer(),
        _loading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: OctoImage.fromSet(
                    image: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const NetworkImage('') as ImageProvider,
                    fit: BoxFit.cover,
                    width: 125,
                    height: 125,
                    octoSet: OctoSet.circleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        text: Icon(SolarIconsBold.galleryAdd,
                            size: 50,
                            color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ),
        const Spacer(),
        ElevatedButton(
            onPressed: _selectedImage == null ? _goHome : _uploadImage,
            child: _selectedImage == null
                ? Text(
                    'skipForNow'.tr,
                  )
                : Text(
                    'continueButton'.tr,
                  ))
      ],
    );
  }
}
