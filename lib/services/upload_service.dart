import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:firebase_storage/firebase_storage.dart';

class UploadService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Uint8List> compressAndCropImage(File file, int size,
      {bool square = false}) async {
    final image = img.decodeImage(await file.readAsBytes());
    final croppedImage = square ? img.copyResizeCropSquare(image!, size: size) : img.copyResize(image!, width: size);
    return img.encodeJpg(croppedImage, quality: 100);
  }

  Future<String> uploadFile(File file, String path, {bool compressed = false, int size = 512, bool square = false}) async {
    try {
      final ref = _storage.ref().child('$path/${file.path}');
      if (compressed) {
        final compressedImage = await compressAndCropImage(file, size, square: square);
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