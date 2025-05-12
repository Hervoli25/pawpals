import 'package:flutter/material.dart';
import '../models/models.dart';

class PlaydateProvider extends ChangeNotifier {
  List<PlaydateModel> _playdates = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PlaydateModel> get playdates => _playdates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get upcoming playdates for a dog
  List<PlaydateModel> getUpcomingPlaydatesForDog(String dogId) {
    final now = DateTime.now();
    return _playdates
        .where((playdate) => 
            (playdate.dogId1 == dogId || playdate.dogId2 == dogId) &&
            playdate.date.isAfter(now) &&
            (playdate.status == 'Accepted' || playdate.status == 'Pending'))
        .toList()
        ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Get all playdates for a dog
  List<PlaydateModel> getAllPlaydatesForDog(String dogId) {
    return _playdates
        .where((playdate) => 
            playdate.dogId1 == dogId || playdate.dogId2 == dogId)
        .toList()
        ..sort((a, b) => b.date.compareTo(a.date)); // Most recent first
  }

  // For demo purposes, we'll use a simple method to load playdates
  // In a real app, this would fetch from a database or API
  Future<void> loadPlaydates(String userId, List<String> dogIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo data
      final now = DateTime.now();
      _playdates = [
        PlaydateModel(
          id: 'playdate1',
          dogId1: 'dog1', // Max
          dogId2: 'other_dog1', // Buddy
          date: now.add(const Duration(hours: 3)),
          location: 'Central Park Dog Run',
          locationDetails: 'Near the entrance at W 85th St',
          status: 'Accepted',
        ),
        PlaydateModel(
          id: 'playdate2',
          dogId1: 'dog2', // Bella
          dogId2: 'other_dog2', // Luna
          date: now.add(const Duration(days: 2)),
          location: 'Riverside Park',
          locationDetails: 'Dog run at 72nd Street',
          status: 'Pending',
        ),
        PlaydateModel(
          id: 'playdate3',
          dogId1: 'other_dog3', // Charlie
          dogId2: 'dog1', // Max
          date: now.subtract(const Duration(days: 3)),
          location: 'Madison Square Park',
          locationDetails: 'Dog run',
          status: 'Completed',
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

  Future<bool> createPlaydate(PlaydateModel playdate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      _playdates.add(playdate);
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

  Future<bool> updatePlaydateStatus(String playdateId, String status) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final index = _playdates.indexWhere((playdate) => playdate.id == playdateId);
      if (index != -1) {
        final updated = _playdates[index].copyWith(status: status);
        _playdates[index] = updated;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Playdate not found';
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

  Future<bool> cancelPlaydate(String playdateId) async {
    return updatePlaydateStatus(playdateId, 'Cancelled');
  }

  Future<bool> acceptPlaydate(String playdateId) async {
    return updatePlaydateStatus(playdateId, 'Accepted');
  }

  Future<bool> rejectPlaydate(String playdateId) async {
    return updatePlaydateStatus(playdateId, 'Rejected');
  }

  Future<bool> completePlaydate(String playdateId) async {
    return updatePlaydateStatus(playdateId, 'Completed');
  }
}
