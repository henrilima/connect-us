import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  static String _baseUrl = 'http://192.168.1.4:3000';

  static Future<void> loadServerUrl() async {
    try {
      final ref = FirebaseDatabase.instance.ref('settings/serverUrl');
      final snapshot = await ref.get();
      if (snapshot.exists) {
        _baseUrl = snapshot.value as String;
        debugPrint('Server URL loaded: $_baseUrl');
      }
    } catch (e) {
      debugPrint('Error loading server URL: $e');
    }
  }

  final Dio _dio = Dio(BaseOptions(baseUrl: _baseUrl));

  Future<bool> uploadPhoto(String userId, File photo) async {
    try {
      String fileName = photo.path.split('/').last;

      FormData formData = FormData.fromMap({
        'userId': userId,
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
      });

      final response = await _dio.post(
        '/api/users/upload-photo',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Upload failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading photo: $e');
      return false;
    }
  }

  Future<bool> uploadDailyPhoto(
    String relationshipId,
    String userId,
    File photo,
  ) async {
    try {
      String fileName = photo.path.split('/').last;

      FormData formData = FormData.fromMap({
        'userId': userId,
        'photo': await MultipartFile.fromFile(photo.path, filename: fileName),
      });

      final response = await _dio.post(
        '/api/relationships/$relationshipId/photos',
        data: formData,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint(
          'Daily photo upload failed with status: ${response.statusCode}',
        );
        return false;
      }
    } catch (e) {
      debugPrint('Error uploading daily photo: $e');
      return false;
    }
  }

  Future<void> downloadFile(String url, String savePath) async {
    try {
      await _dio.download(url, savePath);
    } catch (e) {
      debugPrint('Error downloading file: $e');
      throw Exception('Failed to download file');
    }
  }

  Future<bool> sendNotification(String token, String title, String body) async {
    try {
      final response = await _dio.post(
        '/api/notifications/send-user',
        data: {'token': token, 'title': title, 'body': body},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        debugPrint('Notification failed with status: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error sending notification: $e');
      return false;
    }
  }
}
