import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

/// Shared gallery boundary for artworks, avatars and covers.
Future<Uint8List?> pickGalleryImage({double maxSize = 1600}) async {
  final file = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: maxSize,
    maxHeight: maxSize,
    imageQuality: 85,
  );
  if (file == null) return null;
  final bytes = await file.readAsBytes();
  if (bytes.length > 10 * 1024 * 1024) {
    throw const FormatException('Choose an image smaller than 10 MB.');
  }
  return bytes;
}
