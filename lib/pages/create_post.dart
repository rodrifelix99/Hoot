import 'package:hoot/app/routes/app_routes.dart';
import 'dart:io';
import 'package:floating_action_bubble/floating_action_bubble.dart';
import 'package:hoot/components/appbar_component.dart';
import 'package:hoot/components/url_preview_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/app/controllers/feed_controller.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:uri_content/uri_content.dart';

import 'package:hoot/models/feed.dart';
import 'package:hoot/app/controllers/auth_controller.dart';

class CreatePostPage extends StatefulWidget {
  final String? feedId;
  const CreatePostPage({super.key, this.feedId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> with SingleTickerProviderStateMixin {
  late FeedController _feedProvider;
  late AuthController _authProvider;
  final TextEditingController _textEditingController = TextEditingController();
  final List<File> _images = [];
  final List<String> _gifs = [];
  bool _isLoading = false;
  String _selectedFeedId = '';
  final TextEditingController _dropdownController = TextEditingController();

  late Animation<double> _animation;
  late AnimationController _animationController;
  
  @override
  void initState() {
    _feedProvider = Get.find<FeedController>();
    _authProvider = Get.find<AuthController>();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 260),
      vsync: this,
    );
    final curvedAnimation = CurvedAnimation(curve: Curves.decelerate, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      TenorGifPicker.init(
        apiKey: 'AIzaSyCnfxvwEYAkFGxYmoKd03VPyXoATuMCXZw',
        locale: 'localeName'.tr,
      );
      await _getFeeds();
    });
  }

  Future _getFeeds() async {
    if (_authProvider.user!.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      List<Feed> feeds = await _feedProvider.getFeeds(_authProvider.user!.uid);
      if (feeds.isEmpty) {
        Navigator.of(context).popAndPushNamed('/create_feed');
      } else {
        setState(() {
          _authProvider.user!.feeds = feeds;
        });
      }
    }
  }

  Future _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null && pickedFile.path.isNotEmpty && pickedFile.path.length <= 1000000) {
      CroppedFile? croppedImage = await ImageCropper().cropImage(
        sourcePath: pickedFile.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Edit image',
              toolbarColor: Theme.of(context).colorScheme.primary,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Edit image',
          )
        ],
      );
      if (croppedImage != null) {
        _images.add(File(croppedImage.path));
      } else {
        _images.add(File(pickedFile.path));
      }
    } else if (pickedFile != null) {
      ToastService.showToast(context, 'imageTooLarge'.tr, true);
    }
    setState(() {});
  }

  bool _isValid() => _textEditingController.text.isNotEmpty && _textEditingController.text.length <= 280 && _selectedFeedId.isNotEmpty;

  Future _createPost() async {
    String text = _textEditingController.text;
    if (_isValid()) {
      try {
        setState(() => _isLoading = true);
        List<String> media = [];
        for (File image in _images) {
          String url = await UploadService().uploadFile(
            image,
            'posts/${_authProvider.user?.uid}',
          );
          media.add(url);
        }
        for (String gif in _gifs) {
          media.add(gif);
        }
        bool code = await _feedProvider.createPost(
          context,
          feedId: _selectedFeedId,
          text: text,
          media: media,
        );
        if (code) {
          Get.back();
        } else {
          setState(() {
            _isLoading = false;
            ToastService.showToast(context, 'somethingWentWrong'.tr, true);
          });
        }
      } on Exception catch (e) {
        setState(() {
          _isLoading = false;
          ToastService.showToast(context, e.toString(), true);
        });
      }
    }
  }

  Future _pickGif() async {
    dynamic data = await TenorGifPickerPage.showAsBottomSheet(context,
        customCategories: _authProvider.user!.feeds!.map((feed) => feed.title).toList() + ['Trending'] + ['Featured'] + ['Reactions'],
        preLoadText: _textEditingController.text.isNotEmpty ? _textEditingController.text : 'Hoot',
    );
    if (data != null) {
      setState(() {
        _gifs.add(data?.mediaFormats['gif'].url);
      });
    }
  }

  int countUrls() {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(_textEditingController.text);
    return matches.length;
  }

  String? _getUrl() {
    RegExp exp = RegExp(r'(?:(?:https?|ftp):\/\/)?[\w/\-?=%.]+\.[\w/\-?=%.]+');
    Iterable<RegExpMatch> matches = exp.allMatches(_textEditingController.text);
    if (matches.isNotEmpty) {
      String url = matches.first.group(0)!; // Extract the matched URL
      if (!url.startsWith('http://') && !url.startsWith('https://')) {
        return 'http://$url'; // Add http:// prefix if not present
      }
      return url;
    } else {
      return null;
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarComponent(
        title: 'createPost'.tr,
        actions: [
          IconButton(
            onPressed: _isValid() ? _createPost : null,
            icon: const Icon(SolarIconsOutline.plain),
          ),
        ],
      ),
      body: _isLoading ? Center(child: LoadingAnimationWidget.inkDrop(
          color: Theme.of(context).colorScheme.onSurface,
          size: 50,
      )) :
      SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            _authProvider.user!.feeds!.isNotEmpty ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownMenu(
                controller: _dropdownController,
                label: Text('selectFeed'.tr),
                width: MediaQuery.of(context).size.width - 40,
                onSelected: (value) => _selectedFeedId = value ?? '',
                dropdownMenuEntries: [
                  for (Feed feed in _authProvider.user!.feeds!)
                    DropdownMenuEntry(
                      value: feed.id,
                      label: feed.title,
                      trailingIcon: feed.private! ? const Icon(SolarIconsOutline.lock) : feed.nsfw! ? const Icon(SolarIconsOutline.xxx) : null,
                    ),
                ]
              ),
            ) : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _textEditingController,
                onChanged: (value) => setState(() {}),
                contentInsertionConfiguration: ContentInsertionConfiguration(
                  onContentInserted : (value) async {
                    FocusScope.of(context).unfocus();
                    final uriContent = UriContent();
                    final uri = Uri.parse(value.uri);
                    final Uint8List data = await uriContent.from(uri);
                    setState(() {
                      _images.add(File.fromRawPath(data));
                    });
                  },
                  allowedMimeTypes: ["image/png", "image/jpeg", "image/gif", "image/webp", "image/bmp", "image/tiff", "image/x-icon", "image/vnd.microsoft.icon"],
                ),
                decoration: InputDecoration(
                  hintText: 'postPlaceholder'.tr,
                  contentPadding: const EdgeInsets.all(20),
                ),
                maxLines: 5,
              ),
            ),
            countUrls() > 1 ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  'onlyOneUrl'.tr,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red),
                ),
              ),
            ) : const SizedBox(),
            _getUrl() != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: UrlPreviewComponent(url: _getUrl()!, isClickable: false),
            ) : const SizedBox(),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      children: _images.map((image) => Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: OctoImage(
                            image: FileImage(image),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            placeholderBuilder: OctoPlaceholder.blurHash(
                              'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                            ),
                            errorBuilder: OctoError.icon(color: Colors.red),
                        ),
                          ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => setState(() => _images.remove(image)),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: const Icon(Icons.close, color: Colors.white),
                            ),
                          ),
                        ),
                        ],
                      )).toList(),
                    ),
                    Row(
                      children: _gifs.map((image) => Container(
                        margin: const EdgeInsets.only(right: 10),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: OctoImage(
                                image: NetworkImage(image),
                                width: 150,
                                height: 150,
                                fit: BoxFit.cover,
                                placeholderBuilder: OctoPlaceholder.blurHash(
                                  'LEHV6nWB2yk8pyo0adR*.7kCMdnj',
                                ),
                                errorBuilder: OctoError.icon(color: Colors.red),
                              ),
                            ),
                            Positioned(
                              top: 5,
                              right: 5,
                              child: GestureDetector(
                                onTap: () => setState(() => _gifs.remove(image)),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: const Icon(Icons.close, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: !_isLoading && (_images.length + _gifs.length) < 10  ? FloatingActionBubble(
        items: <Bubble>[
          Bubble(
            title: 'addImage'.tr,
            iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
            bubbleColor : Theme.of(context).colorScheme.primaryContainer,
            icon: SolarIconsBold.cameraAdd,
            titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            onPress: _pickImage,
          ),
          Bubble(
            title: 'addGif'.tr,
            iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
            bubbleColor : Theme.of(context).colorScheme.primaryContainer,
            icon: SolarIconsBold.galleryAdd,
            titleStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
            onPress: _pickGif,
          ),
        ],
        animation: _animation,
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        iconColor: Theme.of(context).colorScheme.onPrimaryContainer,
        iconData: SolarIconsOutline.widgetAdd,
        backGroundColor: Theme.of(context).colorScheme.primaryContainer,
      ) : null,
    );
  }
}
