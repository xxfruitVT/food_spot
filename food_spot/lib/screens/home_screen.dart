import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_spot/screens/category_detail_screen.dart';
import '../services/firestore_service.dart';
import 'detail_screen.dart';

class CategoryModel {
  final String title;
  final String description;
  final String image;

  CategoryModel({
    required this.title,
    required this.description,
    required this.image,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final service = FirestoreService();
  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  List<QueryDocumentSnapshot> allFoods = [];
  Timer? _debounce;

  final List<CategoryModel> categories = [
    CategoryModel(
      title: "restaurants",
      description: "Best places to eat",
      image: "https://images.unsplash.com/photo-1552566626-52f8b828add9",
    ),
    CategoryModel(
      title: "bars & cafe",
      description: "Hangout spots",
      image: "https://images.unsplash.com/photo-1514933651103-005eec06c04b",
    ),
  ];

  bool matchesSearch(QueryDocumentSnapshot food) {
    final q = searchText.toLowerCase();

    final name = food['name'].toString().toLowerCase();
    final category = food['category'].toString().toLowerCase();
    final desc = food['description'].toString().toLowerCase();

    return name.contains(q) || category.contains(q) || desc.contains(q);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: StreamBuilder<QuerySnapshot>(
        stream: service.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            allFoods = snapshot.data!.docs;
          }

          final filteredFoods = allFoods.where(matchesSearch).toList();

          return CustomScrollView(
            slivers: [
              // ================= HERO HEADER =================
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 60, 20, 25),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Hi 👋",
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),

                      const SizedBox(height: 6),

                      const Text(
                        "Find your favorite Place",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // SEARCH BAR
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            _debounce = Timer(
                              const Duration(milliseconds: 250),
                              () => setState(() {
                                searchText = val;
                              }),
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: "Search food...",
                            border: InputBorder.none,
                            icon: Icon(Icons.search),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),

              // ================= CATEGORY =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return _categoryCard(categories[index]);
                          },
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Recommended",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 10)),

              // ================= FOOD LIST =================
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _foodCard(filteredFoods[index]),
                  childCount: filteredFoods.length,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ================= CATEGORY CARD =================
  Widget _categoryCard(CategoryModel c) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                CategoryDetailScreen(categoryTitle: c.title.toLowerCase()),
          ),
        );
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: NetworkImage(c.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
          padding: const EdgeInsets.all(10),
          alignment: Alignment.bottomLeft,
          child: Text(
            c.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  // ================= FOOD CARD =================
  Widget _foodCard(QueryDocumentSnapshot food) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,

        leading: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 60,
            height: 60,
            child: food['image'].toString().startsWith("http")
                ? Image.network(food['image'], fit: BoxFit.cover)
                : Image.file(File(food['image']), fit: BoxFit.cover),
          ),
        ),

        title: Text(
          food['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        subtitle: Text(food['category']),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
          );
        },
      ),
    );
  }
}
