import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

/// Interface for uploading post media to Firebase Storage.
abstract class BaseStorageService {
  Future<List<String>> uploadPostImages(String postId, List<File> files);
}

/// Default implementation uploading to the `posts` folder.
class StorageService implements BaseStorageService {
  final FirebaseStorage _storage;

  StorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  @override
  Future<List<String>> uploadPostImages(String postId, List<File> files) async {
    final urls = <String>[];
    for (var i = 0; i < files.length; i++) {
      final file = files[i];
      final ref = _storage.ref().child('posts').child(postId).child('$i.jpg');
      await ref.putFile(file);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }
}
