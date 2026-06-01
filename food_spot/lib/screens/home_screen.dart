import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/food_cart.dart';
import 'add_food_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text('Food Spot')),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodScreen()),
          );
        },
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getFoods(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var foods = snapshot.data!.docs;

          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              var food = foods[index];

              return FoodCard(food: food);
            },
          );
        },
      ),
    );
  }
}
