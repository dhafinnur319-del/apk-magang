import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // ⚠️ GANTI dengan milikmu dari Cloudinary Console
  static const String cloudName = 'ISI_CLOUD_NAME_KAMU';
  static const String uploadPreset = 'ISI_PRESET_NAME_KAMU';

  /// Upload file ke Cloudinary. Return URL publik atau null jika gagal.
  static Future<String?> uploadFile(File file, {String? folder}) async {
    try {
      final uri = Uri.parse(
        'https://api.cloudinary.com/v1_1/$cloudName/upload',
      );

      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      if (folder != null) {
        request.fields['folder'] = folder;
      }

      request.files.add(await http.MultipartFile.fromPath('file', file.path));

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