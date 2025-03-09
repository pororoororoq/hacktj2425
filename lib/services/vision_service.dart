// vision_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:googleapis/vision/v1.dart' as vision;
import 'package:googleapis_auth/auth_io.dart';

class VisionService {
  final ServiceAccountCredentials credentials;

  VisionService(this.credentials);

  static Future<ServiceAccountCredentials> loadCredentials(String path) async {
    final jsonString = await rootBundle.loadString(path);
    final jsonMap = jsonDecode(jsonString);
    return ServiceAccountCredentials.fromJson(jsonMap);
  }

  Future<List<String>> detectLabels(File imageFile) async {
    final scopes = [vision.VisionApi.cloudPlatformScope];

    final client = await clientViaServiceAccount(credentials, scopes);

    final visionApi = vision.VisionApi(client);

    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);

    final request = vision.BatchAnnotateImagesRequest(requests: [
      vision.AnnotateImageRequest(
        image: vision.Image(content: base64Image),
        features: [vision.Feature(type: 'LABEL_DETECTION', maxResults: 10)],
      ),
    ]);

    final response = await visionApi.images.annotate(request);

    client.close();

    if (response.responses?.isNotEmpty ?? false) {
      final labels = response.responses!.first.labelAnnotations;
      return labels?.map((label) => label.description ?? '').toList() ?? [];
    } else {
      throw Exception('Failed to load labels');
    }
  }
}
