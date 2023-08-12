import 'dart:io';
import 'package:hoot/components/url_preview_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tenor_gif_picker/flutter_tenor_gif_picker.dart';
import 'package:hoot/services/error_service.dart';
import 'package:hoot/services/feed_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hoot/services/upload_service.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:octo_image/octo_image.dart';
import 'package:provider/provider.dart';
import 'package:uri_content/uri_content.dart';

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
  final List<File> _images = [];
  final List<String> _gifs = [];
  bool _isLoading = false;
  String _selectedFeedId = '';
  
  @override
  void initState() {
    _feedProvider = Provider.of<FeedProvider>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);
    TenorGifPicker.init(
        apiKey: 'AIzaSyCnfxvwEYAkFGxYmoKd03VPyXoATuMCXZw',
        locale: 'pt_PT',
        clientKey: 'test_app',
        country: 'PT',
    );
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
          widget.feedId == null ? _selectedFeedId = feeds[0].id : _selectedFeedId = widget.feedId!;
        });
      }
    } else {
      setState(() {
        widget.feedId == null ? _selectedFeedId = _authProvider.user!.feeds![0].id : _selectedFeedId = widget.feedId!;
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
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.createPost),
        actions: [
          IconButton(
            onPressed: _isValid() ? _createPost : null,
            icon: const LineIcon(LineIcons.paperPlane),
          ),
        ],
      ),
      body: _isLoading ? Center(child: LoadingAnimationWidget.inkDrop(
          color: Theme.of(context).colorScheme.onSurface,
          size: 50,
      )) :
      SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            _authProvider.user!.feeds!.isNotEmpty ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      AppLocalizations.of(context)!.selectFeed,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  DropdownButton(
                    value: _selectedFeedId,
                    onChanged: (value) => setState(() => _selectedFeedId = value.toString()),
                    borderRadius: BorderRadius.circular(10),
                    isExpanded: true,
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
                  ),
                ],
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
                  hintText: AppLocalizations.of(context)!.postPlaceholder,
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
                  AppLocalizations.of(context)!.onlyOneUrl,
                  textAlign: TextAlign.left,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.red),
                ),
              ),
            ) : const SizedBox(),
            _getUrl() != null ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: UrlPreviewComponent(url: _getUrl()!, isClickable: false),
            ) : const SizedBox(),
            _images.length + _gifs.length < 10 ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Chip(
                    avatar: const LineIcon(LineIcons.plus),
                    label: Text(AppLocalizations.of(context)!.addImage),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _pickGif,
                  child: Chip(
                    avatar: const LineIcon(LineIcons.plus),
                    label: Text(AppLocalizations.of(context)!.addGif),
                  ),
                ),
              ],
            ) : const SizedBox(),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Column(
                children: [
                  Row(
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
                  Row(
                    children: _gifs.map((image) => Padding(
                      padding: const EdgeInsets.all(8.0),
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
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
