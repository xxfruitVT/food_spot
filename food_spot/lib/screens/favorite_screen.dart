import 'package:flutter/material.dart';
import '../services/favorite_service.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {}); // force refresh setiap masuk tab
  }

  @override
  Widget build(BuildContext context) {
    final favorites = FavoriteService.favorites;

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

      body: favorites.isEmpty
          ? const Center(
              child: Text('No Favorites Yet', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final food = favorites[index];

                return Card(
                  child: ListTile(
                    leading: Image.network(
                      food['image'],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                    title: Text(food['name']),
                    subtitle: Text(food['category']),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          FavoriteService.removeFavorite(food);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
