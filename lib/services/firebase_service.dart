import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/models.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Getters
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;

  // Auth methods
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      // Create user with email and password
      final UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);

        // Create user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'id': userCredential.user!.uid,
          'name': name,
          'email': email,
          'profile_pic': null,
          'dog_ids': [],
          'created_at': FieldValue.serverTimestamp(),
          'updated_at': FieldValue.serverTimestamp(),
        });

        return UserModel(
          id: userCredential.user!.uid,
          name: name,
          email: email,
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      if (userCredential.user != null) {
        // Get user profile from Firestore
        final userData =
            await _firestore
                .collection('users')
                .doc(userCredential.user!.uid)
                .get();

        if (userData.exists) {
          return UserModel(
            id: userCredential.user!.uid,
            name: userData['name'],
            email: userData['email'],
            profilePic: userData['profile_pic'],
            dogIds: List<String>.from(userData['dog_ids'] ?? []),
          );
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Dog methods
  Future<List<DogModel>> getDogs(String userId) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('dogs')
              .where('owner_id', isEqualTo: userId)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return DogModel.fromMap({
          'id': doc.id,
          'name': data['name'],
          'breed': data['breed'],
          'age': data['age'],
          'size': data['size'],
          'photoUrl': data['photo_url'],
          'ownerId': data['owner_id'],
          'temperament': data['temperament'],
        });
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<DogModel> addDog(DogModel dog) async {
    try {
      // Add dog to Firestore
      final docRef = await _firestore.collection('dogs').add({
        'name': dog.name,
        'breed': dog.breed,
        'age': dog.age,
        'size': dog.size,
        'photo_url': dog.photoUrl,
        'owner_id': dog.ownerId,
        'temperament': dog.temperament,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Update user's dog_ids array
      await _firestore.collection('users').doc(dog.ownerId).update({
        'dog_ids': FieldValue.arrayUnion([docRef.id]),
        'updated_at': FieldValue.serverTimestamp(),
      });

      // Get the created dog with its ID
      final dogSnapshot = await docRef.get();
      final dogData = dogSnapshot.data()!;

      return DogModel.fromMap({
        'id': docRef.id,
        'name': dogData['name'],
        'breed': dogData['breed'],
        'age': dogData['age'],
        'size': dogData['size'],
        'photoUrl': dogData['photo_url'],
        'ownerId': dogData['owner_id'],
        'temperament': dogData['temperament'],
      });
    } catch (e) {
      rethrow;
    }
  }

  // Upload file to Firebase Storage
  Future<String?> uploadFile(
    String storagePath,
    String filePath,
    String fileName,
  ) async {
    try {
      // Create a File object from the file path
      final file = File(filePath);

      // Upload file to Firebase Storage
      final ref = _storage.ref().child('$storagePath/$fileName');
      await ref.putFile(file);

      // Get the download URL
      final url = await ref.getDownloadURL();
      return url;
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  // Appointment methods
  Future<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      // Get all dogs owned by the user
      final dogsSnapshot =
          await _firestore
              .collection('dogs')
              .where('owner_id', isEqualTo: userId)
              .get();

      final dogIds = dogsSnapshot.docs.map((doc) => doc.id).toList();

      // Get appointments for all dogs
      final appointmentsSnapshot =
          await _firestore
              .collection('appointments')
              .where('dog_id', whereIn: dogIds)
              .get();

      return appointmentsSnapshot.docs.map((doc) {
        final data = doc.data();
        return AppointmentModel(
          id: doc.id,
          dogId: data['dog_id'],
          title: data['title'],
          dateTime: (data['date_time'] as Timestamp).toDate(),
          location: data['location'],
          notes: data['notes'],
          type: data['type'],
          isCompleted: data['is_completed'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Place methods
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('places').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlaceModel(
          id: doc.id,
          name: data['name'],
          category: data['category'],
          latitude: data['latitude'],
          longitude: data['longitude'],
          address: data['address'],
          description: data['description'],
          photoUrl: data['photo_url'],
          rating: data['rating'],
          amenities: data['amenities'],
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add more methods as needed for other collections
}
