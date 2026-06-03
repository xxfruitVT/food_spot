import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
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

  // Daftar halaman berdasarkan urutan index IndexedStack
  final List<Widget> pages = [
    const HomeScreen(), // index 0
    const SearchScreen(), // index 1
    const MapScreen(), // index 2
    const AddFoodScreen(), // index 3 (Halaman khusus tombol "+")
    const FavoriteScreen(), // index 4
    const ProfileScreen(), // index 5
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

      /// PERBAIKAN: Tombol "+" hanya dirender jika currentIndex == 0 (Hanya di HomeScreen)
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
                onPressed: () {
                  setState(() {
                    currentIndex = 3; // Mengarah ke AddFoodScreen
                  });
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                highlightElevation: 0,
                shape: const CircleBorder(),
                child: const Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            )
          : null, // Jika bukan di HomeScreen (index 0), tombol "+" disembunyikan (null)

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

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
            // Sinkronisasi highlight active icon di bottom bar
            currentIndex: currentIndex == 3
                ? 0 // Jika sedang di AddFoodScreen, hilangkan highlight sementara (kembali ke home)
                : (currentIndex > 3 ? currentIndex - 1 : currentIndex),
            onTap: (index) {
              setState(() {
                // SISI KIRI: Home (0), Search (1), Map (2) -> Cocok dengan index pages
                if (index <= 2) {
                  currentIndex = index;
                }
                // SISI KANAN: Favorite (3), Profile (4) -> Harus ditambah 1 agar meloncat ke index 4 dan 5 di pages
                else {
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
              /// SISI KIRI
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded, size: 28),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_rounded, size: 28),
                label: 'Search',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.location_on_rounded, size: 28),
                label: 'Map',
              ),

              /// SISI KANAN
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite, size: 26),
                label: 'Favorite', // Tombol ini di bar bernilai index 3
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded, size: 28),
                label: 'Profile', // Tombol ini di bar bernilai index 4
              ),
            ],
          ),
        ),
      ),
    );
  }
}
