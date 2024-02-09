import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

Future<File?> takeImageOption({required ImageSource source}) async {
  File? file;
  try {
    XFile? image = await ImagePicker().pickImage(
      source: source,
      imageQuality: 100,
    );
    if (image == null) return null;
    file = File(image.path);
  } on PlatformException catch (e) {
    file = null;
    debugPrint('No Image found. Error: $e');
  }

  debugPrint('Image Found: $file');
  return file;
}
