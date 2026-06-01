import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FoodCard extends StatelessWidget {
  final dynamic food;

  const FoodCard({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(10),
      child: ListTile(
        leading: CachedNetworkImage(
          imageUrl: food['image'],
          width: 60,
          height: 60,
          fit: BoxFit.cover,
        ),
        title: Text(food['name']),
        subtitle: Text(food['category']),
        trailing: Text(food['rating'].toString()),
      ),
    );
  }
}
