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
      title: "Bars & Cafe",
      description: "Hangout spots",
      image: "https://images.unsplash.com/photo-1514933651103-005eec06c04b",
    ),
  ];

  // ================= SEARCH LOGIC (UPDATED) =================
  bool matchesSearch(QueryDocumentSnapshot food) {
    final query = searchText.toLowerCase();

    final name = food['name'].toString().toLowerCase();
    final category = food['category'].toString().toLowerCase();
    final desc = food['description'].toString().toLowerCase();

    return name.contains(query) ||
        category.contains(query) ||
        desc.contains(query);
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

          // FILTER SEARCH (SMOOTH + MULTI FIELD)
          var filteredFoods = allFoods.where(matchesSearch).toList();

          return CustomScrollView(
            slivers: [
              // ================= APP BAR =================
              SliverAppBar(
                expandedHeight: 180,
                pinned: true,
                backgroundColor: Colors.orange,
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    "Home",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                    ),
                  ),
                ),
              ),

              // ================= BODY =================
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ================= SEARCH BAR (FIXED + SMOOTH) =================
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            _debounce = Timer(
                              const Duration(milliseconds: 300),
                              () {
                                setState(() {
                                  searchText = val;
                                });
                              },
                            );
                          },
                          decoration: const InputDecoration(
                            hintText: "Search food, restaurant...",
                            prefixIcon: Icon(Icons.search),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Categories",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 140,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            final c = categories[index];
                            return _categoryCard(c);
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

              // ================= FOOD LIST =================
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return _foodCard(filteredFoods[index]);
                }, childCount: filteredFoods.length),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 20)),
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
          borderRadius: BorderRadius.circular(18),
          image: DecorationImage(
            image: NetworkImage(c.image),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            ),
          ),
          alignment: Alignment.bottomLeft,
          padding: const EdgeInsets.all(10),
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
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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

        subtitle: Text(
          food['category'],
          style: TextStyle(color: Colors.grey.shade600),
        ),

        trailing: const Icon(Icons.arrow_forward_ios, size: 16),

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
