import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';

class SupabaseProvider extends ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseService get service => _supabaseService;
  SupabaseClient get client => _supabase;

  // Helper method to upload a file to Supabase storage
  Future<String?> uploadFile(
    String bucketName,
    String filePath,
    String fileName,
  ) async {
    try {
      // Create a File object from the file path
      final file = File(filePath);

      await _supabase.storage.from(bucketName).upload(fileName, file);

      // Get the public URL
      final url = _supabase.storage.from(bucketName).getPublicUrl(fileName);

      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Helper method to delete a file from Supabase storage
  Future<bool> deleteFile(String bucketName, String fileName) async {
    try {
      await _supabase.storage.from(bucketName).remove([fileName]);
      return true;
    } catch (e) {
      debugPrint('Error deleting file: $e');
      return false;
    }
  }
}
