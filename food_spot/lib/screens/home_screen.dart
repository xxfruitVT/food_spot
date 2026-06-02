import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../widgets/food_cart.dart';
import 'add_food_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = FirestoreService();

  /// SEARCH CONTROLLER
  final TextEditingController searchController = TextEditingController();

  /// SEARCH VALUE
  String searchText = "";

  /// CATEGORY
  String selectedCategory = "All";

  /// CATEGORY LIST
  final List<String> categories = [
    "All",
    "Burger",
    "Pizza",
    "Noodle",
    "Drink",
    "Rice",
    "Snack",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// FLOATING BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.orange,
        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          "Add Food",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),

        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddFoodScreen()),
          );
        },
      ),

      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: service.getFoods(),

          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            /// ALL DATA
            var foods = snapshot.data?.docs ?? [];

            /// =========================
            /// SEARCH FILTER
            /// =========================
            var filteredFoods = foods.where((food) {
              String name = food['name'].toString().toLowerCase();

              String category = food['category'].toString().toLowerCase();

              /// SEARCH
              bool matchSearch = name.contains(searchText.toLowerCase());

              /// CATEGORY
              bool matchCategory =
                  selectedCategory == "All" ||
                  category == selectedCategory.toLowerCase();

              return matchSearch && matchCategory;
            }).toList();

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// ======================
                  /// HEADER
                  /// ======================
                  Padding(
                    padding: const EdgeInsets.all(20),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: const [
                            Text(
                              "Food Spot",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 5),

                            Text(
                              "Discover delicious foods 🍔",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),

                        Container(
                          padding: const EdgeInsets.all(12),

                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),

                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),

                          child: const Icon(Icons.person, color: Colors.orange),
                        ),
                      ],
                    ),
                  ),

                  /// ======================
                  /// SEARCH BAR
                  /// ======================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),

                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),

                      child: TextField(
                        controller: searchController,

                        onChanged: (value) {
                          setState(() {
                            searchText = value;
                          });
                        },

                        decoration: InputDecoration(
                          hintText: "Search food here...",

                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: searchText.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();

                                    setState(() {
                                      searchText = "";
                                    });
                                  },

                                  icon: const Icon(Icons.close),
                                )
                              : null,

                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.all(18),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// ======================
                  /// BANNER
                  /// ======================
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),

                    padding: const EdgeInsets.all(25),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      ),

                      borderRadius: BorderRadius.circular(30),

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
                                "Today's Special",
                                style: TextStyle(color: Colors.white70),
                              ),

                              SizedBox(height: 10),

                              Text(
                                "Find Your\nFavorite Food",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Icon(
                          Icons.fastfood,
                          size: 90,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ======================
                  /// CATEGORY TITLE
                  /// ======================
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),

                    child: Text(
                      "Categories",
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// ======================
                  /// CATEGORY LIST
                  /// ======================
                  SizedBox(
                    height: 50,

                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,

                      padding: const EdgeInsets.symmetric(horizontal: 20),

                      itemCount: categories.length,

                      itemBuilder: (context, index) {
                        String category = categories[index];

                        bool isSelected = selectedCategory == category;

                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCategory = category;
                            });
                          },

                          child: Container(
                            margin: const EdgeInsets.only(right: 12),

                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),

                            decoration: BoxDecoration(
                              color: isSelected ? Colors.orange : Colors.white,

                              borderRadius: BorderRadius.circular(18),

                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),

                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),

                            child: Text(
                              category,

                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// ======================
                  /// POPULAR TITLE
                  /// ======================
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        const Text(
                          "Popular Foods",
                          style: TextStyle(
                            fontSize: 23,
                            fontWeight: FontWeight.bold,
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
                            "${filteredFoods.length} Foods",

                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// ======================
                  /// EMPTY SEARCH
                  /// ======================
                  if (filteredFoods.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 80),

                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.orange,
                            ),

                            SizedBox(height: 20),

                            Text(
                              "Food Not Found",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 10),

                            Text(
                              "Try searching another food",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),

                  /// ======================
                  /// FOOD LIST
                  /// ======================
                  if (filteredFoods.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,

                      physics: const NeverScrollableScrollPhysics(),

                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      itemCount: filteredFoods.length,

                      itemBuilder: (context, index) {
                        var food = filteredFoods[index];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 18),

                          child: InkWell(
                            borderRadius: BorderRadius.circular(22),

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

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
