import 'package:flutter/material.dart';
import '../models/models.dart';
import '../services/places_service.dart';

class PlaceProvider extends ChangeNotifier {
  final PlacesService _placesService = PlacesService();
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get places by category
  List<PlaceModel> getPlacesByCategory(String category) {
    return _places.where((place) => place.category == category).toList();
  }

  // Get nearby places
  Future<List<PlaceModel>> getNearbyPlaces(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      return await _placesService.getNearbyPlaces(
        latitude,
        longitude,
        radiusInKm,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Get nearby dog parks
  Future<List<PlaceModel>> getNearbyDogParks(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      return await _placesService.getNearbyDogParks(
        latitude,
        longitude,
        radiusInKm,
      );
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Load places from Firestore
  Future<void> loadPlaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _places = await _placesService.getPlaces();

      // If no places exist in Firestore yet, add some demo data
      if (_places.isEmpty) {
        await _addDemoPlaces();
        _places = await _placesService.getPlaces();
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load places by category
  Future<void> loadPlacesByCategory(String category) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _places = await _placesService.getPlacesByCategory(category);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to add demo places if none exist
  Future<void> _addDemoPlaces() async {
    final demoPlaces = [
      PlaceModel(
        name: 'Central Park Dog Run',
        category: 'Park',
        latitude: 40.7812,
        longitude: -73.9665,
        address: 'Central Park, New York, NY',
        description: 'Large off-leash area for dogs to play',
        rating: 4.8,
        amenities: {
          'water': true,
          'seating': true,
          'shade': true,
          'waste_bags': true,
        },
      ),
      PlaceModel(
        name: 'Barking Dog Cafe',
        category: 'Cafe',
        latitude: 40.7731,
        longitude: -73.9545,
        address: '1678 3rd Ave, New York, NY',
        description: 'Dog-friendly cafe with outdoor seating',
        rating: 4.5,
        amenities: {
          'water_bowls': true,
          'dog_treats': true,
          'outdoor_seating': true,
        },
      ),
      PlaceModel(
        name: 'Pet Paradise Hotel',
        category: 'Hotel',
        latitude: 40.7589,
        longitude: -73.9851,
        address: '123 W 28th St, New York, NY',
        description: 'Luxury pet-friendly hotel with dog walking services',
        rating: 4.7,
        amenities: {
          'pet_beds': true,
          'dog_walking': true,
          'grooming': true,
          'pet_sitting': true,
        },
      ),
      PlaceModel(
        name: 'Doggy Beach',
        category: 'Beach',
        latitude: 40.5763,
        longitude: -73.9943,
        address: 'Coney Island, Brooklyn, NY',
        description: 'Dog-friendly beach area (seasonal)',
        rating: 4.3,
        amenities: {
          'off_leash_area': true,
          'water_access': true,
          'waste_stations': true,
        },
      ),
    ];

    for (final place in demoPlaces) {
      await _placesService.addPlace(place);
    }
  }

  Future<bool> addPlace(PlaceModel place) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Add place to Firestore
      final addedPlace = await _placesService.addPlace(place);

      // Add to local state
      _places.add(addedPlace);

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

  Future<bool> updatePlace(PlaceModel updatedPlace) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Update place in Firestore
      await _placesService.updatePlace(updatedPlace);

      // Update in local state
      final index = _places.indexWhere((place) => place.id == updatedPlace.id);
      if (index != -1) {
        _places[index] = updatedPlace;
      } else {
        // If not found in local state, add it
        _places.add(updatedPlace);
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

  Future<bool> deletePlace(String placeId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete place from Firestore
      await _placesService.deletePlace(placeId);

      // Remove from local state
      _places.removeWhere((place) => place.id == placeId);

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
}
