import 'package:flutter/material.dart';
import '../models/models.dart';

class PlaceProvider extends ChangeNotifier {
  List<PlaceModel> _places = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlaceModel> get places => _places;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get places by category
  List<PlaceModel> getPlacesByCategory(String category) {
    return _places
        .where((place) => place.category == category)
        .toList();
  }

  // Get nearby places (simplified for demo)
  List<PlaceModel> getNearbyPlaces(double latitude, double longitude, double radiusInKm) {
    // In a real app, we would calculate distance between coordinates
    // For demo, we'll just return all places
    return _places;
  }

  // For demo purposes, we'll use a simple method to load places
  // In a real app, this would fetch from a database or API
  Future<void> loadPlaces() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo data
      _places = [
        PlaceModel(
          id: 'place1',
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
          id: 'place2',
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
          id: 'place3',
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
          id: 'place4',
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

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addPlace(PlaceModel place) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _places.add(place);
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final index = _places.indexWhere((place) => place.id == updatedPlace.id);
      if (index != -1) {
        _places[index] = updatedPlace;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Place not found';
        _isLoading = false;
        notifyListeners();
        return false;
      }
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

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
