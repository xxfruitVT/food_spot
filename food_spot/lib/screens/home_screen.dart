import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/food_cart.dart';
import 'add_food_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = FirestoreService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Food Spot',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Discover delicious foods around you',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Food',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.fastfood_rounded,
                      size: 70,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Foods Available',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Text(
                      'Start adding your favorite foods and build your delicious collection',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                    ),
                  ),
                ],
              ),
            );
          }

          var foods = snapshot.data!.docs;

          return Column(
            children: [
              // Top Banner
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Today’s Special',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Find Your\nFavorite Food',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 80,
                    ),
                  ],
                ),
              ),

              // Food List Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Popular Foods',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${foods.length} Items',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // Food List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: foods.length,
                  itemBuilder: (context, index) {
                    var food = foods[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => DetailScreen(food: food),
                            ),
                          );
                        },
                        child: FoodCard(food: food),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
