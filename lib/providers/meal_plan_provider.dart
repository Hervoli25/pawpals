import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/models.dart';

class MealPlanProvider extends ChangeNotifier {
  Map<String, List<MealPlanModel>> _mealPlans =
      {}; // dogId -> list of meal plans
  bool _isLoading = false;
  String? _errorMessage;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Get meal plans for a specific dog
  List<MealPlanModel> getMealPlansForDog(String dogId) {
    return _mealPlans[dogId] ?? [];
  }

  // Get today's meal plan for a specific dog
  MealPlanModel? getTodaysMealPlan(String dogId) {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final dogMealPlans = _mealPlans[dogId] ?? [];
    try {
      return dogMealPlans.firstWhere((mealPlan) {
        final mealPlanDate = DateTime(
          mealPlan.date.year,
          mealPlan.date.month,
          mealPlan.date.day,
        );
        return mealPlanDate.isAtSameMomentAs(todayDate);
      });
    } catch (e) {
      return null;
    }
  }

  // Load meal plans from Firebase
  Future<void> loadMealPlans(List<String> dogIds) async {
    if (dogIds.isEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, List<MealPlanModel>> mealPlans = {};

      // Query Firestore for meal plans for each dog
      for (final dogId in dogIds) {
        final snapshot =
            await _firestore
                .collection('meal_plans')
                .where('dogId', isEqualTo: dogId)
                .orderBy('date', descending: true)
                .get();

        if (snapshot.docs.isNotEmpty) {
          // Convert Firestore documents to MealPlanModel objects
          final dogMealPlans =
              snapshot.docs.map((doc) {
                final data = doc.data();

                // Parse meal items
                List<MealItem> parseItems(List<dynamic>? items) {
                  if (items == null) return [];
                  return items.map((item) => MealItem.fromMap(item)).toList();
                }

                return MealPlanModel(
                  id: doc.id,
                  dogId: data['dogId'],
                  date: (data['date'] as Timestamp).toDate(),
                  breakfast: parseItems(data['breakfast']),
                  lunch: parseItems(data['lunch']),
                  dinner: parseItems(data['dinner']),
                  snacks: parseItems(data['snacks']),
                );
              }).toList();

          mealPlans[dogId] = dogMealPlans;
        } else {
          // If no meal plans exist for this dog, create default ones
          final today = DateTime.now();

          // Create default meal plan for today
          final defaultMealPlan = MealPlanModel(
            dogId: dogId,
            date: today,
            breakfast: [
              MealItem(
                name: '1 cup premium kibble',
                description: 'High-quality dry food',
              ),
            ],
            lunch: [
              MealItem(
                name: '½ cup cooked vegetables',
                description: 'Carrots, green beans, and peas',
              ),
            ],
            dinner: [
              MealItem(
                name: '1 cup premium kibble',
                description: 'High-quality dry food',
              ),
            ],
            snacks: [
              MealItem(
                name: 'Training treats',
                description: 'Small, low-calorie treats for training',
              ),
            ],
          );

          // Save the default meal plan to Firestore
          await addMealPlan(defaultMealPlan);

          // Add to local state
          mealPlans[dogId] = [defaultMealPlan];
        }
      }

      _mealPlans = mealPlans;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> addMealPlan(MealPlanModel mealPlan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert meal items to maps
      List<Map<String, dynamic>> itemsToMap(List<MealItem> items) {
        return items.map((item) => item.toMap()).toList();
      }

      // Create data map for Firestore
      final data = {
        'dogId': mealPlan.dogId,
        'date': mealPlan.date,
        'breakfast': itemsToMap(mealPlan.breakfast),
        'lunch': itemsToMap(mealPlan.lunch),
        'dinner': itemsToMap(mealPlan.dinner),
        'snacks': itemsToMap(mealPlan.snacks),
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef = await _firestore.collection('meal_plans').add(data);

      // Update the meal plan with the Firestore document ID
      final updatedMealPlan = MealPlanModel(
        id: docRef.id,
        dogId: mealPlan.dogId,
        date: mealPlan.date,
        breakfast: mealPlan.breakfast,
        lunch: mealPlan.lunch,
        dinner: mealPlan.dinner,
        snacks: mealPlan.snacks,
      );

      // Update local state
      final dogId = mealPlan.dogId;
      if (!_mealPlans.containsKey(dogId)) {
        _mealPlans[dogId] = [];
      }

      _mealPlans[dogId]!.add(updatedMealPlan);
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

  Future<bool> updateMealPlan(MealPlanModel updatedMealPlan) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Convert meal items to maps
      List<Map<String, dynamic>> itemsToMap(List<MealItem> items) {
        return items.map((item) => item.toMap()).toList();
      }

      // Create data map for Firestore
      final data = {
        'dogId': updatedMealPlan.dogId,
        'date': updatedMealPlan.date,
        'breakfast': itemsToMap(updatedMealPlan.breakfast),
        'lunch': itemsToMap(updatedMealPlan.lunch),
        'dinner': itemsToMap(updatedMealPlan.dinner),
        'snacks': itemsToMap(updatedMealPlan.snacks),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      await _firestore
          .collection('meal_plans')
          .doc(updatedMealPlan.id)
          .update(data);

      // Update local state
      final dogId = updatedMealPlan.dogId;
      final mealPlans = _mealPlans[dogId] ?? [];

      final index = mealPlans.indexWhere(
        (mealPlan) => mealPlan.id == updatedMealPlan.id,
      );

      if (index != -1) {
        mealPlans[index] = updatedMealPlan;
        _mealPlans[dogId] = mealPlans;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        // If not found in local state, add it
        if (!_mealPlans.containsKey(dogId)) {
          _mealPlans[dogId] = [];
        }
        _mealPlans[dogId]!.add(updatedMealPlan);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMealPlan(String dogId, String mealPlanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Delete from Firestore
      await _firestore.collection('meal_plans').doc(mealPlanId).delete();

      // Update local state
      final mealPlans = _mealPlans[dogId] ?? [];
      mealPlans.removeWhere((mealPlan) => mealPlan.id == mealPlanId);
      _mealPlans[dogId] = mealPlans;

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
