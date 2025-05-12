import 'package:flutter/material.dart';
import '../models/models.dart';

class MealPlanProvider extends ChangeNotifier {
  Map<String, List<MealPlanModel>> _mealPlans = {}; // dogId -> list of meal plans
  bool _isLoading = false;
  String? _errorMessage;

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

  // For demo purposes, we'll use a simple method to load meal plans
  // In a real app, this would fetch from a database or API
  Future<void> loadMealPlans(List<String> dogIds) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      // Demo data
      final Map<String, List<MealPlanModel>> mealPlans = {};
      
      for (final dogId in dogIds) {
        final today = DateTime.now();
        final yesterday = today.subtract(const Duration(days: 1));
        final tomorrow = today.add(const Duration(days: 1));
        
        // Create sample meal items
        final breakfast = [
          MealItem(
            name: '1 cup premium kibble',
            description: 'High-quality dry food',
          ),
          MealItem(
            name: '½ tbsp fish oil supplement',
            description: 'For healthy skin and coat',
          ),
        ];
        
        final lunch = [
          MealItem(
            name: '½ cup cooked vegetables',
            description: 'Carrots, green beans, and peas',
          ),
          MealItem(
            name: '1 dental chew treat',
            description: 'For dental health',
          ),
        ];
        
        final dinner = [
          MealItem(
            name: '1 cup premium kibble',
            description: 'High-quality dry food',
          ),
          MealItem(
            name: '¼ cup protein supplement',
            description: 'Cooked chicken or beef',
          ),
        ];
        
        final snacks = [
          MealItem(
            name: 'Training treats',
            description: 'Small, low-calorie treats for training',
          ),
        ];
        
        // Create meal plans for yesterday, today, and tomorrow
        mealPlans[dogId] = [
          MealPlanModel(
            dogId: dogId,
            date: yesterday,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            snacks: snacks,
          ),
          MealPlanModel(
            dogId: dogId,
            date: today,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            snacks: snacks,
          ),
          MealPlanModel(
            dogId: dogId,
            date: tomorrow,
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            snacks: snacks,
          ),
        ];
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final dogId = mealPlan.dogId;
      if (!_mealPlans.containsKey(dogId)) {
        _mealPlans[dogId] = [];
      }
      
      _mealPlans[dogId]!.add(mealPlan);
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
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final dogId = updatedMealPlan.dogId;
      final mealPlans = _mealPlans[dogId] ?? [];
      
      final index = mealPlans.indexWhere(
          (mealPlan) => mealPlan.id == updatedMealPlan.id);
      
      if (index != -1) {
        mealPlans[index] = updatedMealPlan;
        _mealPlans[dogId] = mealPlans;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Meal plan not found';
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

  Future<bool> deleteMealPlan(String dogId, String mealPlanId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

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
