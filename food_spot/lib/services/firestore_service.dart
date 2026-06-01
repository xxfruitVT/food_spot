import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final CollectionReference foods = FirebaseFirestore.instance.collection(
    'food_spots',
  );

  Future addFood({
    required String name,
    required String category,
    required String description,
    required String image,
    required double rating,
  }) async {
    await foods.add({
      'name': name,
      'category': category,
      'description': description,
      'image': image,
      'rating': rating,
    });
  }

  Stream<QuerySnapshot> getFoods() {
    return foods.snapshots();
  }

  Future deleteFood(String id) async {
    await foods.doc(id).delete();
  }
}
