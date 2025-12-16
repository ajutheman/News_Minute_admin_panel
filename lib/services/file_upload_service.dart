import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../utils/constants.dart';

class FileUploadService {
  static Future<String?> uploadImage(File file) async {
    try {
      var request = http.MultipartRequest(
        'POST', 
        Uri.parse('${Constants.baseUrl}/upload')
      );
      
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          contentType: MediaType('image', 'jpeg'), // Simplified content type
        ),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final relativePath = data['filePath'];
        // Backend returns /uploads/filename.jpg, we need full URL for frontend display
        // But for saving in DB, relative path is fine if we construct it later,
        // HOWEVER, to be safe and consistent, let's return the full URL if needed or handle it in UI.
        // Let's assume the UI wants the full URL to display immediately.
        // But wait, the backend `baseUrl` in Constants has `/api` at the end.
        // We need the root URL.
        final rootUrl = Constants.baseUrl.replaceAll('/api', '');
        return '$rootUrl$relativePath';
      } else {
        print('Upload failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Upload Error: $e');
      return null;
    }
  }
}
