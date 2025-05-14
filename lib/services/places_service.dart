import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geoflutterfire2/geoflutterfire2.dart';
import '../models/models.dart';

class PlacesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GeoFlutterFire _geo = GeoFlutterFire();

  // Get all places
  Future<List<PlaceModel>> getPlaces() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore.collection('places').get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlaceModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Place',
          category: data['category'] ?? 'Other',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          address: data['address'],
          description: data['description'],
          photoUrl: data['photo_url'],
          rating:
              data['rating'] != null
                  ? (data['rating'] as num).toDouble()
                  : null,
          amenities: data['amenities'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get places by category
  Future<List<PlaceModel>> getPlacesByCategory(String category) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('places')
              .where('category', isEqualTo: category)
              .get();

      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return PlaceModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Place',
          category: data['category'] ?? 'Other',
          latitude: (data['latitude'] ?? 0.0).toDouble(),
          longitude: (data['longitude'] ?? 0.0).toDouble(),
          address: data['address'],
          description: data['description'],
          photoUrl: data['photo_url'],
          rating:
              data['rating'] != null
                  ? (data['rating'] as num).toDouble()
                  : null,
          amenities: data['amenities'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Get nearby places using GeoFlutterFire
  Future<List<PlaceModel>> getNearbyPlaces(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      // Create a geoFirePoint
      GeoFirePoint center = _geo.point(
        latitude: latitude,
        longitude: longitude,
      );

      // Get places within the radius
      final List<DocumentSnapshot> docs =
          await _geo
              .collection(collectionRef: _firestore.collection('places'))
              .within(
                center: center,
                radius: radiusInKm,
                field: 'location',
                strictMode: true,
              )
              .first;

      // Convert to PlaceModel objects
      return docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Extract latitude and longitude from GeoPoint
        double lat = data['latitude'];
        double lng = data['longitude'];

        // If using GeoPoint directly, extract from there
        if (data['location'] != null && data['location']['geopoint'] != null) {
          final GeoPoint geoPoint = data['location']['geopoint'];
          lat = geoPoint.latitude;
          lng = geoPoint.longitude;
        }

        return PlaceModel(
          id: doc.id,
          name: data['name'] ?? 'Unknown Place',
          category: data['category'] ?? 'Other',
          latitude: lat,
          longitude: lng,
          address: data['address'],
          description: data['description'],
          photoUrl: data['photo_url'],
          rating:
              data['rating'] != null
                  ? (data['rating'] as num).toDouble()
                  : null,
          amenities: data['amenities'] as Map<String, dynamic>?,
        );
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add a new place
  Future<PlaceModel> addPlace(PlaceModel place) async {
    try {
      // Create a GeoFirePoint
      GeoFirePoint geoPoint = _geo.point(
        latitude: place.latitude,
        longitude: place.longitude,
      );

      // Prepare data for Firestore
      final data = {
        'name': place.name,
        'category': place.category,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'location': geoPoint.data, // Add GeoFirePoint data
        'address': place.address,
        'description': place.description,
        'photo_url': place.photoUrl,
        'rating': place.rating,
        'amenities': place.amenities,
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Add to Firestore
      final docRef = await _firestore.collection('places').add(data);

      // Get the created place with its ID
      final placeSnapshot = await docRef.get();
      final placeData = placeSnapshot.data()!;

      return PlaceModel(
        id: docRef.id,
        name: placeData['name'],
        category: placeData['category'],
        latitude: placeData['latitude'],
        longitude: placeData['longitude'],
        address: placeData['address'],
        description: placeData['description'],
        photoUrl: placeData['photo_url'],
        rating: placeData['rating'],
        amenities: placeData['amenities'],
      );
    } catch (e) {
      rethrow;
    }
  }

  // Update an existing place
  Future<void> updatePlace(PlaceModel place) async {
    try {
      // Create a GeoFirePoint
      GeoFirePoint geoPoint = _geo.point(
        latitude: place.latitude,
        longitude: place.longitude,
      );

      // Prepare data for Firestore
      final data = {
        'name': place.name,
        'category': place.category,
        'latitude': place.latitude,
        'longitude': place.longitude,
        'location': geoPoint.data, // Update GeoFirePoint data
        'address': place.address,
        'description': place.description,
        'photo_url': place.photoUrl,
        'rating': place.rating,
        'amenities': place.amenities,
        'updated_at': FieldValue.serverTimestamp(),
      };

      // Update in Firestore
      await _firestore.collection('places').doc(place.id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete a place
  Future<void> deletePlace(String placeId) async {
    try {
      await _firestore.collection('places').doc(placeId).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Get dog parks specifically
  Future<List<PlaceModel>> getDogParks() async {
    return getPlacesByCategory('Park');
  }

  // Get nearby dog parks
  Future<List<PlaceModel>> getNearbyDogParks(
    double latitude,
    double longitude,
    double radiusInKm,
  ) async {
    try {
      final List<PlaceModel> nearbyPlaces = await getNearbyPlaces(
        latitude,
        longitude,
        radiusInKm,
      );
      return nearbyPlaces.where((place) => place.category == 'Park').toList();
    } catch (e) {
      rethrow;
    }
  }
}
