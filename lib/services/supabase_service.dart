import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Auth methods
  Future<UserModel?> signUp(String email, String password, String name) async {
    try {
      final AuthResponse response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user != null) {
        // The trigger function will automatically create a user profile
        // No need to manually insert

        return UserModel(id: response.user!.id, name: name, email: email);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> signIn(String email, String password) async {
    try {
      final AuthResponse response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Get user profile from the database
        final userData =
            await _supabase
                .from('users')
                .select()
                .eq('id', response.user!.id)
                .single();

        return UserModel(
          id: response.user!.id,
          name: userData['name'],
          email: userData['email'],
          profilePic: userData['profile_pic'],
          dogIds: List<String>.from(userData['dog_ids'] ?? []),
        );
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // Dog methods
  Future<List<DogModel>> getDogs(String userId) async {
    try {
      final data = await _supabase.from('dogs').select().eq('owner_id', userId);

      return data
          .map<DogModel>(
            (dog) => DogModel.fromMap({
              'id': dog['id'],
              'name': dog['name'],
              'breed': dog['breed'],
              'age': dog['age'],
              'size': dog['size'],
              'photoUrl': dog['photo_url'],
              'ownerId': dog['owner_id'],
              'temperament': dog['temperament'],
            }),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<DogModel> addDog(DogModel dog) async {
    try {
      final data =
          await _supabase
              .from('dogs')
              .insert({
                'name': dog.name,
                'breed': dog.breed,
                'age': dog.age,
                'size': dog.size,
                'photo_url': dog.photoUrl,
                'owner_id': dog.ownerId,
                'temperament': dog.temperament,
              })
              .select()
              .single();

      // Update user's dog_ids array
      await _supabase.rpc(
        'add_dog_to_user',
        params: {'user_id': dog.ownerId, 'dog_id': data['id']},
      );

      return DogModel.fromMap({
        'id': data['id'],
        'name': data['name'],
        'breed': data['breed'],
        'age': data['age'],
        'size': data['size'],
        'photoUrl': data['photo_url'],
        'ownerId': data['owner_id'],
        'temperament': data['temperament'],
      });
    } catch (e) {
      rethrow;
    }
  }

  // Appointment methods
  Future<List<AppointmentModel>> getAppointments(String userId) async {
    try {
      final data = await _supabase
          .from('appointments')
          .select('*, dogs!inner(owner_id)')
          .eq('dogs.owner_id', userId);

      return data
          .map<AppointmentModel>(
            (appointment) => AppointmentModel(
              id: appointment['id'],
              dogId: appointment['dog_id'],
              title: appointment['title'],
              dateTime: DateTime.parse(appointment['date_time']),
              location: appointment['location'],
              notes: appointment['notes'],
              type: appointment['type'],
              isCompleted: appointment['is_completed'],
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Playdate methods
  Future<List<PlaydateModel>> getPlaydates(
    String userId,
    List<String> dogIds,
  ) async {
    try {
      final data = await _supabase
          .from('playdates')
          .select()
          .or(
            'dog_id1.in.(${dogIds.join(",")}),dog_id2.in.(${dogIds.join(",")})',
          );

      return data
          .map<PlaydateModel>(
            (playdate) => PlaydateModel(
              id: playdate['id'],
              dogId1: playdate['dog_id1'],
              dogId2: playdate['dog_id2'],
              date: DateTime.parse(playdate['date']),
              location: playdate['location'],
              locationDetails: playdate['location_details'],
              status: playdate['status'],
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Place methods
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final data = await _supabase.from('places').select();

      return data
          .map<PlaceModel>(
            (place) => PlaceModel(
              id: place['id'],
              name: place['name'],
              category: place['category'],
              latitude: place['latitude'],
              longitude: place['longitude'],
              address: place['address'],
              description: place['description'],
              photoUrl: place['photo_url'],
              rating: place['rating'],
              amenities: place['amenities'],
            ),
          )
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Meal plan methods
  Future<List<MealPlanModel>> getMealPlans(List<String> dogIds) async {
    try {
      final data = await _supabase
          .from('meal_plans')
          .select('*, meal_items(*)')
          .filter('dog_id', 'in', '(${dogIds.join(",")})');

      Map<String, List<MealPlanModel>> mealPlansByDog = {};

      for (var plan in data) {
        final dogId = plan['dog_id'];

        if (!mealPlansByDog.containsKey(dogId)) {
          mealPlansByDog[dogId] = [];
        }

        final mealItems = plan['meal_items'] as List;

        final breakfast =
            mealItems
                .where((item) => item['meal_type'] == 'breakfast')
                .map(
                  (item) => MealItem(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'],
                    imageUrl: item['image_url'],
                    nutritionInfo: item['nutrition_info'],
                  ),
                )
                .toList();

        final lunch =
            mealItems
                .where((item) => item['meal_type'] == 'lunch')
                .map(
                  (item) => MealItem(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'],
                    imageUrl: item['image_url'],
                    nutritionInfo: item['nutrition_info'],
                  ),
                )
                .toList();

        final dinner =
            mealItems
                .where((item) => item['meal_type'] == 'dinner')
                .map(
                  (item) => MealItem(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'],
                    imageUrl: item['image_url'],
                    nutritionInfo: item['nutrition_info'],
                  ),
                )
                .toList();

        final snacks =
            mealItems
                .where((item) => item['meal_type'] == 'snack')
                .map(
                  (item) => MealItem(
                    id: item['id'],
                    name: item['name'],
                    description: item['description'],
                    imageUrl: item['image_url'],
                    nutritionInfo: item['nutrition_info'],
                  ),
                )
                .toList();

        mealPlansByDog[dogId]!.add(
          MealPlanModel(
            id: plan['id'],
            dogId: plan['dog_id'],
            date: DateTime.parse(plan['date']),
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            snacks: snacks,
          ),
        );
      }

      List<MealPlanModel> allMealPlans = [];
      mealPlansByDog.forEach((_, plans) {
        allMealPlans.addAll(plans);
      });

      return allMealPlans;
    } catch (e) {
      rethrow;
    }
  }
}
