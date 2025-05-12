import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/models.dart';
import '../services/firebase_service.dart';

class DogProvider extends ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  List<DogModel> _dogs = [];
  bool _isLoading = false;
  String? _errorMessage;
  DogModel? _lastAddedDog;
  bool _dogJustAdded = false;

  List<DogModel> get dogs => _dogs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DogModel? get lastAddedDog => _lastAddedDog;
  bool get dogJustAdded => _dogJustAdded;

  // Call this after handling the dogJustAdded flag
  void resetDogJustAdded() {
    _dogJustAdded = false;
    notifyListeners();
  }

  Future<void> loadDogs(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Load dogs from Firebase
      _dogs = await _firebaseService.getDogs(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addDog(DogModel dog) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add dog to Firebase
      final newDog = await _firebaseService.addDog(dog);
      _dogs.add(newDog);

      // Set the last added dog and flag
      _lastAddedDog = newDog;
      _dogJustAdded = true;

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDog(DogModel updatedDog) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update dog in Firebase
      await _firebaseService.firestore
          .collection('dogs')
          .doc(updatedDog.id)
          .update({
            'name': updatedDog.name,
            'breed': updatedDog.breed,
            'age': updatedDog.age,
            'size': updatedDog.size,
            'photo_url': updatedDog.photoUrl,
            'temperament': updatedDog.temperament,
            'updated_at': FieldValue.serverTimestamp(),
          });

      // Update local state
      final index = _dogs.indexWhere((dog) => dog.id == updatedDog.id);
      if (index != -1) {
        _dogs[index] = updatedDog;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteDog(String dogId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete dog from Firebase
      await _firebaseService.firestore.collection('dogs').doc(dogId).delete();

      // Update local state
      _dogs.removeWhere((dog) => dog.id == dogId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  DogModel? getDogById(String dogId) {
    try {
      return _dogs.firstWhere((dog) => dog.id == dogId);
    } catch (e) {
      return null;
    }
  }
}
