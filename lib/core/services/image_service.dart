import 'dart:io';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();
  ImageService();

  Future<List<XFile>> pickImages() async {
    final images = await _picker.pickMultiImage();
    return images; // pickMultiImage returns List<XFile>
  }

  Future<XFile?> pickCamera() async {
    return await _picker.pickImage(source: ImageSource.camera);
  }

  Future<File> copyToDirectory(XFile xfile, Directory targetDir) async {
    final newPath = '${targetDir.path}/${DateTime.now().microsecondsSinceEpoch}_${xfile.name}';
    final file = File(xfile.path);
    return file.copy(newPath);
  }
}
