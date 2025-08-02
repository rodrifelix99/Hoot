import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as img;
import 'package:blurhash/blurhash.dart';

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
        // Resize if the image is larger than 1080px on either side.
        if (processed.width > 1080 || processed.height > 1080) {
          processed = img.copyResize(processed, width: 1080);
        }
        data = Uint8List.fromList(img.encodeJpg(processed, quality: 85));
        hash = await BlurHash.encode(data, 4, 3);
      }

      await ref.putData(data, SettableMetadata(contentType: 'image/jpeg'));
      final url = await ref.getDownloadURL();
      results.add(UploadedPostImage(url: url, blurHash: hash));
    }
    return results;
  }
}
