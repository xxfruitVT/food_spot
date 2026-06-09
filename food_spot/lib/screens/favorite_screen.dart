import 'dart:io';
import 'package:flutter/material.dart';
import 'package:food_spot/screens/detail_screen.dart';
import '../services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          'Favorites',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
      ),

      body: ValueListenableBuilder(
        valueListenable: FavoriteService.favorites,
        builder: (context, favorites, _) {
          if (favorites.isEmpty) {
            return const Center(
              child: Text('No Favorites Yet', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final food = favorites[index];

              return Card(
                child: ListTile(
                  onTap: () {
                    // 👈 INI YANG KAMU TAMBAH
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailScreen(food: food),
                      ),
                    );
                  },

                  leading:
                      (food['image'] != null &&
                          food['image'].toString().isNotEmpty &&
                          food['image'].toString().startsWith('http'))
                      ? Image.network(
                          food['image'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        )
                      : Image.file(
                          File(food['image']),
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.image_not_supported);
                          },
                        ),

                  title: Text(food['name']),
                  subtitle: Text(food['category']),

                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      FavoriteService.removeFavorite(food);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
