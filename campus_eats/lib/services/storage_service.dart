import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

/// Handles image uploads to Firebase Storage.
/// Cross-platform compatible (Mobile, Web, Desktop) via XFile.
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Uploads image from [XFile] to `menu_images/{fileName}` and returns download URL.
  Future<String> uploadMenuImage({
    required XFile file,
    required String fileName,
  }) async {
    final ref = _storage.ref().child('menu_images/$fileName');
    
    // Read bytes from XFile for cross-platform support
    final bytes = await file.readAsBytes();
    
    final uploadTask = ref.putData(
      bytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    final snapshot = await uploadTask;
    return snapshot.ref.getDownloadURL();
  }

  static String generateFileName(String prefix) =>
      '${prefix}_${DateTime.now().millisecondsSinceEpoch}.jpg';

  Future<void> deleteByUrl(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (_) {}
  }
}
