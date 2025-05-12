import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../services/firebase_service.dart';

class FirebaseProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FirebaseService get service => _firebaseService;
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Helper method to upload a file to Firebase storage
  Future<String?> uploadFile(
    String storagePath,
    String filePath,
    String fileName,
  ) async {
    try {
      // Create a File object from the file path
      final file = File(filePath);

      // Create a reference to the file location in Firebase Storage
      final ref = _storage.ref().child('$storagePath/$fileName');
      
      // Upload the file
      await ref.putFile(file);

      // Get the download URL
      final url = await ref.getDownloadURL();

      return url;
    } catch (e) {
      debugPrint('Error uploading file: $e');
      return null;
    }
  }

  // Helper method to get current user
  User? get currentUser => _auth.currentUser;

  // Helper method to listen to auth state changes
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Helper method to get a document reference
  DocumentReference<Map<String, dynamic>> getDocumentReference(String collection, String docId) {
    return _firestore.collection(collection).doc(docId);
  }

  // Helper method to get a collection reference
  CollectionReference<Map<String, dynamic>> getCollectionReference(String collection) {
    return _firestore.collection(collection);
  }

  // Helper method to create a document with auto-generated ID
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    return await _firestore.collection(collection).add(data);
  }

  // Helper method to set a document with specific ID
  Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
    {bool merge = false}
  ) async {
    await _firestore.collection(collection).doc(docId).set(data, SetOptions(merge: merge));
  }

  // Helper method to update a document
  Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  // Helper method to delete a document
  Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  // Helper method to get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String collection,
    String docId,
  ) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  // Helper method to query a collection
  Query<Map<String, dynamic>> queryCollection(String collection) {
    return _firestore.collection(collection);
  }
}
