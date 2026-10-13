import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  // ⚠️ GANTI dengan milikmu dari Cloudinary Console
  static const String cloudName = 'bpsu7log';
  static const String uploadPreset = 'simagang_uploads';

  /// Upload file ke Cloudinary. Menerima XFile (kompatibel Web + Mobile).
  /// Return URL publik atau null jika gagal.
  static Future<String?> uploadFile(XFile file, {String? folder}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      // Baca bytes — bekerja di Web & Mobile (tanpa dart:io)
      final bytes = await file.readAsBytes();

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: file.name,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200) {
        final body = await response.stream.bytesToString();
        final data = jsonDecode(body);
        return data['secure_url'] as String?;
      } else {
        final body = await response.stream.bytesToString();
        print('Cloudinary error ${response.statusCode}: $body');
        return null;
      }
    } catch (e) {
      print('Cloudinary exception: $e');
      return null;
    }
  }
}