import 'dart:convert';
import 'dart:typed_data';

/// Returns true if [data] is a base64 string or a data URI for an image.
bool isBase64ImageData(String data) {
  if (data.startsWith('data:image')) {
    return true;
  }
  final regex = RegExp(r'^[A-Za-z0-9+/]+={0,2}$');
  if (data.length % 4 != 0 || !regex.hasMatch(data)) {
    return false;
  }
  try {
    base64Decode(data);
    return true;
  } catch (_) {
    return false;
  }
}

/// Decodes a base64 [data] string or data URI into bytes.
Uint8List decodeBase64Image(String data) {
  final base64String = data.startsWith('data:') ? data.split(',').last : data;
  return base64Decode(base64String);
}
