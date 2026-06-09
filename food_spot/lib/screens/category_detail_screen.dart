import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen.dart';

class CategoryDetailScreen extends StatelessWidget {
  final String categoryTitle;

  const CategoryDetailScreen({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('food_spots').snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("Database kosong"));
          }

          final allFoods = snapshot.data!.docs;

          // FILTER CATEGORY (case insensitive)
          final foods = allFoods.where((food) {
            final data = food.data() as Map<String, dynamic>;

            final category = (data['category'] ?? '')
                .toString()
                .toLowerCase()
                .trim();

            final selected = categoryTitle.toLowerCase().trim();

            return category == selected;
          }).toList();

          if (foods.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.restaurant_menu, size: 80, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Tidak ada data di kategori ini"),
                ],
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 160,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(categoryTitle),
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.orange, Colors.deepOrange],
                      ),
                    ),
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final food = foods[index];
                  final data = food.data() as Map<String, dynamic>;

                  // AMBIL IMAGE DENGAN AMAN
                  final imageUrl =
                      (data['image'] ?? data['imageUrl'] ?? data['img'] ?? '')
                          .toString();

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: imageUrl.isNotEmpty && imageUrl.startsWith('http')
                          ? Image.network(
                              imageUrl,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 40);
                              },
                            )
                          : Image.file(
                              File(imageUrl),
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            ),
                    ),

                    title: Text(data['name'] ?? 'No Name'),

                    subtitle: Text(data['category'] ?? ''),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(food: food),
                        ),
                      );
                    },
                  );
                }, childCount: foods.length),
              ),
            ],
          );
        },
      ),
    );
  }
}
