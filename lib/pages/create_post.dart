import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';

import '../models/feed.dart';
import '../services/auth_provider.dart';

class CreatePostPage extends StatefulWidget {
  final String? feedId;
  const CreatePostPage({super.key, this.feedId});

  @override
  State<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  late FeedProvider _feedProvider;
  late AuthProvider _authProvider;
  final TextEditingController _textEditingController = TextEditingController();
  List<File> _images = [];
  bool _isLoading = false;
  String _selectedFeedId = '';
  
  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    super.initState();
    _getFeeds();
  }

  Future _getFeeds() async {
    if (_authProvider.user!.feeds == null || _authProvider.user!.feeds!.isEmpty) {
      List<Feed> feeds = await _feedProvider.getFeeds(_authProvider.user!.uid);
      if (feeds.isEmpty) {
        Navigator.of(context).popAndPushNamed('/create_feed');
      } else {
        setState(() {
          _authProvider.user!.feeds = feeds;
          _selectedFeedId = feeds[0].id;
        });
      }
    } else {
      setState(() {
        _selectedFeedId = _authProvider.user!.feeds![0].id;
      });
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
      ToastService.showToast(context, AppLocalizations.of(context)!.imageTooLarge, true);
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
        bool code = await _feedProvider.createPost(
          context,
          feedId: _selectedFeedId,
          text: text,
          media: media,
        );
        if (code) {
          Navigator.pop(context);
        } else {
          setState(() {
            _isLoading = false;
            ToastService.showToast(context, AppLocalizations.of(context)!.somethingWentWrong, true);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createPost),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) :
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _authProvider.user!.feeds!.isNotEmpty ? DropdownButton(
              value: _selectedFeedId,
              onChanged: (value) => setState(() => _selectedFeedId = value.toString()),
              borderRadius: BorderRadius.circular(10),
              items: _authProvider.user!.feeds!.map((feed) => DropdownMenuItem(
                value: feed.id,
                child: Row(
                  children: [
                    Text(feed.title),
                    const SizedBox(width: 10),
                    feed.private == true ? const LineIcon(LineIcons.lock) : const SizedBox(),
                    feed.nsfw == true ? const LineIcon(LineIcons.exclamationTriangle) : const SizedBox(),
                  ],
                ),
              )).toList(),
            ) : const Center(child: CircularProgressIndicator()),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: TextField(
                controller: _textEditingController,
                onChanged: (value) => setState(() {}),
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.postPlaceholder,
                  contentPadding: const EdgeInsets.all(20),
                ),
                maxLines: 5,
              ),
            ),
            _images.length < 10 ? GestureDetector(
              onTap: _pickImage,
              child: Chip(
                avatar: LineIcon(LineIcons.plus),
                label: Text('Add image'),
              ),
            ) : const SizedBox(),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _images.map((image) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
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
                  ),
                )).toList(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isValid() ? _createPost : null,
              child: Text(AppLocalizations.of(context)!.publish),
            )
          ],
        ),
      ),
    );
  }
}
