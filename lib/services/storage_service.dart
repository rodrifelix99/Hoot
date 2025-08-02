import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash/blurhash.dart';
import 'package:hoot/util/constants.dart';

/// Interface for uploading post media to Firebase Storage.
class UploadedPostImage {
  final String url;
  final String blurHash;

  UploadedPostImage({required this.url, required this.blurHash});
}

abstract class BaseStorageService {
  Future<List<UploadedPostImage>> uploadPostImages(
      String postId, List<File> files);
}

/// Default implementation uploading to the `posts` folder.
class StorageService implements BaseStorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<UploadedPostImage>> uploadPostImages(
      String postId, List<File> files) async {
    final results = <UploadedPostImage>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ref = _storage.ref().child('posts').child(postId).child('$i.jpg');

      Uint8List data = await file.readAsBytes();
      String hash = '';
      final decoded = img.decodeImage(data);
      if (decoded != null) {
        img.Image processed = decoded;
        // Resize if the image is larger than [kMaxImageDimension] on either side.
        if (processed.width > kMaxImageDimension ||
            processed.height > kMaxImageDimension) {
          processed = img.copyResize(processed, width: kMaxImageDimension);
        }
        data =
            Uint8List.fromList(img.encodeJpg(processed, quality: kJpegQuality));
        hash = await BlurHash.encode(data, kBlurHashX, kBlurHashY);
      }

      await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      results.add(UploadedPostImage(url: url, blurHash: hash));
    }
    return results;
  }
}
