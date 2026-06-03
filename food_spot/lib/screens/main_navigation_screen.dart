import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'search_screen.dart';
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

  // Halaman MapScreen sekarang dipindah ke index 2 (tengah) jika ingin diakses via tombol tengah
  final List<Widget> pages = [
    const HomeScreen(),
    const SearchScreen(),
    const MapScreen(), // Halaman Map / Tambah Postingan
    const FavoriteScreen(),
    const ProfileScreen(),
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

      /// TOMBOL "+" SEKARANG DI TENGAH
      floatingActionButton: Container(
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
            // Aksi tombol tengah: Pindah ke MapScreen atau halaman postingan
            setState(() {
              currentIndex = 2;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          shape: const CircleBorder(),
          child: const Icon(
            Icons
                .add_rounded, // Kamu bisa ganti ke Icons.location_on_rounded jika ini untuk Map
            color: Colors.white,
            size: 36,
          ),
        ),
      ),

      // Mengubah lokasi FAB tepat di tengah-tengah bawah melayang
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
            currentIndex: currentIndex == 2
                ? 0
                : currentIndex, // Highlight handling untuk tombol tengah
            onTap: (index) {
              // Jika user menekan item, sesuaikan indexnya agar melompati space tengah jika diperlukan
              setState(() {
                if (index >= 2) {
                  currentIndex =
                      index +
                      1; // Geser index karena posisi ke-2 diisi oleh tombol "+"
                } else {
                  currentIndex = index;
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

              /// SISI KANAN
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
