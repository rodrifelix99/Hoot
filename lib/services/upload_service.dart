import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Uint8List> compressAndCropImage(File file, int size) async {
    final image = img.decodeImage(await file.readAsBytes());
    final squaredImage = img.copyResizeCropSquare(image!, size: size);
    return img.encodeJpg(squaredImage, quality: 90);
  }

  Future<String> uploadFile(File file, String path, {bool compressed = false, int size = 512}) async {
    try {
      final ref = _storage.ref().child('$path/${file.path}');
      if (compressed) {
        final compressedImage = await compressAndCropImage(file, size);
        final uploadTask = ref.putData(compressedImage);
        final snapshot = await uploadTask.whenComplete(() => null);
        final url = await snapshot.ref.getDownloadURL();
        return url;
      } else {
        final uploadTask = ref.putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);
        final url = await snapshot.ref.getDownloadURL();
        return url;
      }
    } catch (e) {
      print(e.toString());
      return '';
    }
  }
}