import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive_io.dart';
import 'dart:convert';



Future<String?> generateRemote3DModel({
  required String originalImagePath,
  String? lipColorHex,
  String? blushColorHex,
  String? eyeshadowColorHex,
  double foundationIntensity = 0.0,
}) async {
  try {
    
    String serverUrl = 'http://167.172.111.39:8000/api/generate-3d'; 

    var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
    request.files.add(await http.MultipartFile.fromPath('file', originalImagePath));

    
    if (lipColorHex != null) request.fields['lip_color'] = lipColorHex;
    if (blushColorHex != null) request.fields['blush_color'] = blushColorHex;
    if (eyeshadowColorHex != null) request.fields['eyeshadow_color'] = eyeshadowColorHex;
    if (foundationIntensity > 0) request.fields['foundation_intensity'] = foundationIntensity.toString();

    debugPrint("Sunucuya makyajlı 3D model isteği gönderiliyor...");

    var response = await request.send().timeout(const Duration(minutes: 3));

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();

      Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String zipPath = '${tempDir.path}/makeup_model_$timestamp.zip';
      String extractDirName = 'makeup_extracted_$timestamp';
      String extractPath = '${tempDir.path}/$extractDirName';

      File zipFile = File(zipPath);
      await zipFile.writeAsBytes(bytes);

      await extractFileToDisk(zipPath, extractPath);

      
      final dir = Directory(extractPath);
      final files = dir.listSync(recursive: true);
      
      for (var file in files) {
        if (file.path.endsWith('.obj')) {
          return file.path;
        }
      }
      debugPrint("Hata: ZIP içinden .obj dosyası çıkmadı");
      return null;

    } else {
      debugPrint("Sunucu Hatası: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("Bağlantı hatası: $e");
    return null;
  }
}

Future<String?> applyMakeupToTexture({
  required String originalImagePath,
  String? lipColorHex,
  String? blushColorHex,
  String? eyeshadowColorHex,
  String? contourColorHex,    
  String? concealerColorHex,  
  String? eyelinerColorHex,   
  String? foundationColorHex, 
  double foundationIntensity = 0.0,
  double concealerIntensity = 0.75,
  String? bronzerColorHex,
  double bronzerIntensity = 0.15,
}) async {
  try {
    String serverUrl = 'http://167.172.111.39:8000/api/apply-makeup-texture'; 

    var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
    request.files.add(await http.MultipartFile.fromPath('file', originalImagePath));

    if (lipColorHex != null) request.fields['lip_color'] = lipColorHex;
    if (blushColorHex != null) request.fields['blush_color'] = blushColorHex;
    if (eyeshadowColorHex != null) request.fields['eyeshadow_color'] = eyeshadowColorHex;
    
    if (contourColorHex != null) request.fields['contour_color'] = contourColorHex;
    if (concealerColorHex != null) request.fields['concealer_color'] = concealerColorHex;
    if (eyelinerColorHex != null) request.fields['eyeliner_color'] = eyelinerColorHex;
    if (foundationColorHex != null) request.fields['foundation_color'] = foundationColorHex;
    if (bronzerColorHex != null) request.fields['bronzer_color'] = bronzerColorHex;

    if (foundationIntensity > 0) request.fields['foundation_intensity'] = foundationIntensity.toString();
    if (bronzerIntensity > 0) request.fields['bronzer_intensity'] = bronzerIntensity.toString();
    request.fields['concealer_intensity'] = concealerIntensity.toString();

    var response = await request.send().timeout(const Duration(minutes: 2));

    if (response.statusCode == 200) {
      var bytes = await response.stream.toBytes();

      Directory tempDir = await getTemporaryDirectory();
      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String extractDirName = 'texture_session_$timestamp';
      String sessionPath = '${tempDir.path}/$extractDirName';
      
      
      await Directory(sessionPath).create(recursive: true);
      
      
      String filename = originalImagePath.replaceAll('\\', '/').split('/').last;
      String newImagePath = '$sessionPath/$filename';

      File imageFile = File(newImagePath);
      await imageFile.writeAsBytes(bytes);

      return newImagePath;
    } else {
      debugPrint("Sunucu Hatası (Texture): ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("Bağlantı hatası (Texture): $e");
    return null;
  }
}


Future<Map<String, dynamic>?> fetchAiColorAnalysis({
  required String imagePath,
  String apiKey = "", 
}) async {
  try {
    String serverUrl = 'http://167.172.111.39:8000/api/analyze-skin'; 

    var request = http.MultipartRequest('POST', Uri.parse(serverUrl));
    request.files.add(await http.MultipartFile.fromPath('file', imagePath));
    if (apiKey.isNotEmpty) {
      request.fields['api_key'] = apiKey;
    }

    var response = await request.send().timeout(const Duration(minutes: 1));

    if (response.statusCode == 200) {
      final respStr = await response.stream.bytesToString();
      return json.decode(respStr);
    } else {
      debugPrint("Renk analiz hatası: ${response.statusCode}");
      return null;
    }
  } catch (e) {
    debugPrint("Renk analiz bağlantı hatası: $e");
    return null;
  }
}