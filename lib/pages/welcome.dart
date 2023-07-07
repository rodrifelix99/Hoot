import 'dart:io';
import 'dart:math';

import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:hoot/models/user.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_picker/image_picker.dart';
import 'package:octo_image/octo_image.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../services/auth_provider.dart';

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
      ThirdScreen(controller: controller),
      FourthScreen(controller: controller)
    ];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Swiper(
          controller: controller,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (BuildContext context, int index) {
            return Stack(
              children: [
                Positioned.fill(
                    child: OctoImage(
                      image: NetworkImage(images[index]),
                      fit: BoxFit.cover,
                      placeholderBuilder: OctoPlaceholder.blurHash(
                        'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                      ),
                    )
                ),
                Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 100, 16, 80),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            Colors.transparent,
                            Colors.black,
                          ],
                        ),
                      ),
                      child: screens[index],
                    )
                ),
              ],
            );
          },
          itemCount: screens.length,
          pagination: SwiperPagination(
            margin: const EdgeInsets.only(bottom: 50),
            builder: DotSwiperPaginationBuilder(
              color: Colors.white,
              activeColor: Theme.of(context).colorScheme.primary,
            ),
          ),
        )
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
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.welcomeTo,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          AppLocalizations.of(context)!.appName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          AppLocalizations.of(context)!.welcomeDescription,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.controller.next(),
          child: Text(AppLocalizations.of(context)!.getStarted),
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
  final TextEditingController _nameController = TextEditingController();

  bool _isNameValid() {
    return _nameController.text.isNotEmpty && _nameController.text.length > 2 && _nameController.text.length < 30;
  }

  Future _onSubmit() async {
    if (_isNameValid() && _nameController.text.isNotEmpty) {
      FocusScope.of(context).unfocus();
      U? user = Provider.of<AuthProvider>(context, listen: false).user;
      if (user != null) {
        user.name = _nameController.text;
        widget.controller.next();
        bool response = await Provider.of<AuthProvider>(context, listen: false).updateUser(user);
        if (!response) {
          widget.controller.move(1, animation: true);
          setState(() {
            ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
          });
        }
      } else {
        print('User is null');
        setState(() {
          ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.whatsYourName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.displayNameDescription,
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: _nameController,
                autocorrect: true,
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                maxLength: 30,
                onChanged: (value) => setState(() {}),
                onSubmitted: (value) => _onSubmit(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.displayName,
                  counter: const SizedBox(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _isNameValid() ? () => _onSubmit() : null,
              icon: Icon(Icons.arrow_right_rounded, color: Theme.of(context).colorScheme.onPrimary),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        _isNameValid() || _nameController.text.isEmpty ? Text(
          AppLocalizations.of(context)!.pressEnterToContinue,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ) : Text(
          AppLocalizations.of(context)!.displayNameTooShort,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.red,
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
  final TextEditingController _usernameController = TextEditingController();
  bool _loading = false;

  bool _isValid() {
    return _usernameController.text.isNotEmpty && _usernameController.text.length >= 6 && _usernameController.text.length <= 15 && !_usernameController.text.contains("@");
  }

  Future _onSubmit() async {
    if (_isValid()) {
      setState(() {
        _loading = true;
      });
      if (await Provider.of<AuthProvider>(context, listen: false).isUsernameAvailable(_usernameController.text)) {
        FocusScope.of(context).unfocus();
        U? user = Provider.of<AuthProvider>(context, listen: false).user;
        if (user != null) {
          user.username = _usernameController.text;
          setState(() {
            _loading = false;
          });
          widget.controller.next();
          bool response = await Provider.of<AuthProvider>(context, listen: false).updateUser(user);
          if (!response) {
            widget.controller.move(2, animation: true);
            setState(() {
              ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
            });
          }
        } else {
          print('User is null');
          setState(() {
            _loading = false;
            ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
          });
        }
      } else {
        setState(() {
          _loading = false;
          ToastService.showToast(context, AppLocalizations.of(context)!.usernameTaken, true);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.letsSpiceItUp,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppLocalizations.of(context)!.usernameDescription,
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        const SizedBox(height: 16),
        _loading ? const Center(
          child: CircularProgressIndicator(),
        ) : Row(
          children: [
            IconButton(
              onPressed: widget.controller.previous,
              icon: Icon(Icons.arrow_left_rounded, color: Theme.of(context).colorScheme.onPrimary),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: TextField(
                controller: _usernameController,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                maxLength: 15,
                onChanged: (value) => setState(() => _usernameController.text.contains("@") ? _usernameController.text = _usernameController.text.replaceAll("@", "") : null),
                onSubmitted: (value) => _onSubmit(),
                decoration: InputDecoration(
                  labelText: AppLocalizations.of(context)!.username,
                  counter: const SizedBox(),
                ),
              ),
            ),
            const SizedBox(width: 20),
            IconButton(
              onPressed: _isValid() ? () => _onSubmit() : null,
              icon: Icon(Icons.arrow_right_rounded, color: Theme.of(context).colorScheme.onPrimary),
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        _isValid() || _usernameController.text.isEmpty ? Text(
          AppLocalizations.of(context)!.pressEnterToContinue,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
          ),
        ) : Text(
          AppLocalizations.of(context)!.displayNameTooShort,
          style: Theme.of(context).textTheme.bodySmall!.copyWith(
            color: Colors.red,
          ),
        ),
      ],
    );
  }
}

class FourthScreen extends StatefulWidget {
  final SwiperController controller;
  const FourthScreen({super.key, required this.controller});

  @override
  State<FourthScreen> createState() => _FourthScreenState();
}

class _FourthScreenState extends State<FourthScreen> {
  bool _loading = false;
  File? _selectedImage;

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

  Future _uploadImage() async {
    if (_selectedImage != null && _selectedImage!.lengthSync() <= 1000000) {
      setState(() {
        _loading = true;
      });

      String uid = Provider.of<AuthProvider>(context, listen: false).user!.uid;
      String smallAvatarUrl = await UploadService().uploadFile(_selectedImage!, 'avatars/$uid/small', compressed: true, size: 50);
      String bigAvatarUrl = await UploadService().uploadFile(_selectedImage!, 'avatars/$uid/big', compressed: true);

      if (smallAvatarUrl.isNotEmpty && bigAvatarUrl.isNotEmpty) {
        U? user = Provider.of<AuthProvider>(context, listen: false).user;
        if (user != null) {
          user.smallProfilePictureUrl = smallAvatarUrl;
          user.largeProfilePictureUrl = bigAvatarUrl;
          bool response = await Provider.of<AuthProvider>(context, listen: false).updateUser(user);
          if (response) {
            Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
          } else {
            setState(() {
              ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
            });
          }
        } else {
          print('User is null');
        }
      } else {
        setState(() {
          ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
        });
      }
      setState(() {
        _loading = false;
      });
    } else {
      setState(() {
        ToastService.showToast(context, AppLocalizations.of(context)!.errorUnknown, true);
      });
    }
  }

  String _getRandomSuccessPhrase() {
    int random = Random().nextInt(3) + 1;
    switch (random) {
      case 1:
        return AppLocalizations.of(context)!.avatarSelectedFunny1;
      case 2:
        return AppLocalizations.of(context)!.avatarSelectedFunny2;
      case 3:
        return AppLocalizations.of(context)!.avatarSelectedFunny3;
      default:
        return AppLocalizations.of(context)!.avatarSelectedFunny1;
    }
  }

  void _goHome() {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.almostThere,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _selectedImage == null ? AppLocalizations.of(context)!.avatarDescription : _getRandomSuccessPhrase(),
          style: const TextStyle(
              color: Colors.white
          ),
        ),
        const SizedBox(height: 20),
        _loading ? const Center(
          child: CircularProgressIndicator(),
        ) : Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: OctoImage.fromSet(
                    image: _selectedImage != null ? FileImage(_selectedImage!) : const NetworkImage("https://i.pinimg.com/originals/bc/55/32/bc553212027810220a07fb992c47fbc3.jpg") as ImageProvider,
                    fit: BoxFit.cover,
                    width: 100,
                    height: 100,
                    octoSet: OctoSet.circleAvatar(
                      backgroundColor: Colors.grey.shade300,
                      text: Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.grey.shade800
                      )
                    ),
                ),
              ),
              const SizedBox(height: 10),
              _selectedImage == null ? TextButton(
                  onPressed: _goHome,
                  child: Text(
                    AppLocalizations.of(context)!.skipForNow,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  )
              ) : ElevatedButton(
                  onPressed: _uploadImage,
                  child: Text(
                    AppLocalizations.of(context)!.continueButton,
                  )
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}