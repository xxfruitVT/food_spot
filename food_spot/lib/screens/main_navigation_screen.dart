import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'add_food_screen.dart';
import 'map_screen.dart';
import 'favorite_screen.dart';
import 'profile_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  late int currentIndex;

  // ✅ SearchScreen DIHAPUS
  final List<Widget> pages = [
    const HomeScreen(), // 0
    const MapScreen(), // 1
    const AddFoodScreen(), // 2
    const FavoriteScreen(), // 3
    const ProfileScreen(), // 4
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      // ================= FLOATING BUTTON =================
      floatingActionButton: currentIndex == 0
          ? Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF43D4CF), Color(0xFF5B8DEF)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF5B8DEF).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                heroTag: "main_nav_fab",
                onPressed: () {
                  setState(() {
                    currentIndex = 2; // AddFoodScreen
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            )
          : null,

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ================= BOTTOM NAV =================
      bottomNavigationBar: Container(
        margin: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: currentIndex > 2 ? currentIndex - 1 : currentIndex,

            onTap: (index) {
              setState(() {
                if (index <= 1) {
                  currentIndex = index;
                } else {
                  currentIndex = index + 1;
                }
              });
            },

            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF4DD0E1),
            unselectedItemColor: Colors.grey.shade400,
            type: BottomNavigationBarType.fixed,
            showSelectedLabels: false,
            showUnselectedLabels: false,

            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_rounded, size: 28),
                label: 'Map',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size: 26),
                label: 'Favorite',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 28),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
