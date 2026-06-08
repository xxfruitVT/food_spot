import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:food_spot/screens/category_detail_screen.dart';
import '../services/firestore_service.dart';
import 'detail_screen.dart';

// Model untuk data kategori
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

  // Data kategori nyata
  final List<CategoryModel> categories = [
    CategoryModel(
      title: "Restaurants",
      description: "Temukan tempat makan terbaik",
      image: "https://images.unsplash.com/photo-1552566626-52f8b828add9",
    ),
    CategoryModel(
      title: "Bars & Cafe",
      description: "Tempat nongkrong favorit",
      image: "https://images.unsplash.com/photo-1514933651103-005eec06c04b",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      body: StreamBuilder<QuerySnapshot>(
        stream: service.getFoods(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          var foods = snapshot.data?.docs ?? [];
          var filteredFoods = foods.where((food) {
            String name = food['name'].toString().toLowerCase();
            return name.contains(searchText.toLowerCase());
          }).toList();

          return CustomScrollView(
            slivers: [
              // 1. Header Elegan dengan SliverAppBar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                centerTitle: true,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  title: Text(
                    "Home",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      // PENYEBAB BUREM: Menggunakan warna dengan opasitas (Misalnya, putih kusam)
                      color: Colors.white.withOpacity(0.6), // <--- Ubah di sini
                    ),
                  ),
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4",
                        fit: BoxFit.cover,
                      ),
                      Container(color: Colors.black.withOpacity(0.3)),
                    ],
                  ),
                ),
              ),

              // 2. Konten Utama
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Bar
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (val) => setState(() => searchText = val),
                          decoration: const InputDecoration(
                            hintText: "Cari makanan atau resto...",
                            prefixIcon: Icon(Icons.search, color: Colors.cyan),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 25),

                      // Grid Kategori
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: categories.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 15,
                            ),
                        itemBuilder: (context, index) =>
                            _buildCategoryCard(categories[index]),
                      ),

                      const SizedBox(height: 25),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Recommended",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              // 3. List Restoran dari Firestore
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _buildFoodItem(filteredFoods[index]),
                  childCount: filteredFoods.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          );
        },
      ),
    );
  }

  // Komponen Kategori Clickable
  Widget _buildCategoryCard(CategoryModel category) {
    return InkWell(
      onTap: () {
        // Tambahkan aksi navigasi di sini
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                CategoryDetailScreen(categoryTitle: category.title),
          ),
        );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Membuka ${category.title}")));
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  category.image,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                category.title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Komponen Item Makanan (ListTile)
  Widget _buildFoodItem(QueryDocumentSnapshot food) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(10),
        leading: Hero(
          tag: food.id, // ID Unik dari Firestore
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              food['image'],
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
        ),
        title: Text(
          food['name'],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(food['category']),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DetailScreen(food: food)),
        ),
      ),
    );
  }
}
