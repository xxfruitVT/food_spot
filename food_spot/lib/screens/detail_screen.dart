import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class DetailScreen extends StatelessWidget {
  final dynamic food;

  const DetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food['name'])),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CachedNetworkImage(
              imageUrl: food['image'],
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food['name'],
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 8),
                      Text(food['category']),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(food['rating'].toString()),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    food['description'],
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.favorite),
                      label: const Text('Add to Favorite'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
