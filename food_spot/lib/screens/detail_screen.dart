import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:food_spot/services/favorite_service.dart';

class DetailScreen extends StatelessWidget {
  final dynamic food;

  const DetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: CustomScrollView(
        slivers: [
          // ================= APP BAR =================
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            backgroundColor: Colors.orange,
            elevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),

            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 20, bottom: 18),
              title: Text(
                food['name'],
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),

              background: Stack(
                fit: StackFit.expand,
                children: [
                  CachedNetworkImage(
                    imageUrl: food['image'],
                    fit: BoxFit.cover,

                    placeholder: (context, url) =>
                        const Center(child: CircularProgressIndicator()),

                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        size: 60,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.2),
                          Colors.black.withOpacity(0.6),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ================= CONTENT =================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // NAME & RATING
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          food['name'],
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star_rounded,
                              color: Colors.orange,
                              size: 22,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              food['rating'].toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // INFO CARDS
                  Row(
                    children: [
                      Expanded(
                        child: _infoCard(
                          icon: Icons.category_rounded,
                          color: Colors.orange,
                          title: "Category",
                          value: food['category'],
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: _infoCard(
                          icon: Icons.local_fire_department,
                          color: Colors.green,
                          title: "Popularity",
                          value: "Trending",
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 14),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Text(
                      food['description'],
                      style: const TextStyle(fontSize: 16, height: 1.7),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // FAVORITE BUTTON (FIXED)
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        FavoriteService.addFavorite(food);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to Favorite ❤️'),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      icon: const Icon(Icons.favorite_border_rounded),

                      label: const Text(
                        'Add to Favorite',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= REUSABLE WIDGET =================
  Widget _infoCard({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color),
          ),

          const SizedBox(height: 12),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),

          const SizedBox(height: 6),

          Text(
            value,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
