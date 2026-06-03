import 'dart:async'; // Ditambahkan untuk mendukung StreamSubscription (Real-time)
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Koordinat default (Jakarta) jika GPS gagal didapatkan di awal
  LatLng _currentPosition = const LatLng(-6.2000, 106.8166);
  final MapController _mapController = MapController();
  bool _isLoading = true;

  // Variabel untuk mengontrol dan mematikan tracking saat pindah halaman
  StreamSubscription<Position>? _positionStreamSubscription;

  // Data tiruan restoran terdekat di sekitar koordinat user
  final List<Map<String, dynamic>> _nearByRestaurants = [
    {
      "name": "Restaurant Pinky",
      "address": "Weasley Street 12",
      "image":
          "https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?w=500",
      "lat": -6.1990,
      "lng": 106.8150,
    },
    {
      "name": "Mexican Restaurant",
      "address": "Hilton Street 50",
      "image":
          "https://images.unsplash.com/photo-1552566626-52f8b828add9?w=500",
      "lat": -6.2015,
      "lng": 106.8180,
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
  }

  // Membersihkan fungsi tracking ketika user keluar dari MapScreen agar baterai tidak boros
  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    super.dispose();
  }

  /// Fungsi Memeriksa Izin GPS dan Mengaktifkan Real-time Tracking
  Future<void> _checkPermissionAndTrack() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. Cek apakah GPS di HP aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Layanan lokasi (GPS) Anda dinonaktifkan.");
      setState(() => _isLoading = false);
      return;
    }

    // 2. Cek izin akses lokasi aplikasi
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackBar("Izin lokasi ditolak.");
        setState(() => _isLoading = false);
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackBar("Izin lokasi ditolak permanen, ubah di pengaturan HP.");
      setState(() => _isLoading = false);
      return;
    }

    // 3. Ambil posisi awal sekali agar peta langsung terbuka di lokasi user tanpa menunggu stream
    try {
      Position initialPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(
            initialPosition.latitude,
            initialPosition.longitude,
          );
          _isLoading = false;
        });
        _mapController.move(_currentPosition, 15.0);
      }
    } catch (e) {
      // Jika gagal mengambil posisi awal, matikan loading dan pakai koordinat default
      setState(() => _isLoading = false);
    }

    // 4. AKTIFKAN PELACAKAN REAL-TIME (STREAM)
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy
                .high, // Akurasi tinggi menggunakan GPS hardware
            distanceFilter:
                3, // Update koordinat map setiap kali HP bergeser minimal 3 meter
          ),
        ).listen((Position position) {
          if (!mounted) return;

          setState(() {
            // Update koordinat marker biru sesuai lokasi HP yang baru secara real-time
            _currentPosition = LatLng(position.latitude, position.longitude);
          });

          // Buka komentar kode di bawah ini jika kamu ingin kamera peta otomatis
          // ikut bergeser ke tengah (lock-center) setiap kali langkah kaki user bergerak:
          // _mapController.move(_currentPosition, _mapController.camera.zoom);
        });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          /// 1. TAMPILAN PETA UTAMA
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4DD0E1)),
                )
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentPosition,
                    initialZoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.foodspot.app',
                    ),

                    /// MARKER PIN (User & Restoran)
                    MarkerLayer(
                      markers: [
                        // Marker posisi asli user (Pin biru ini akan bergerak real-time)
                        Marker(
                          point: _currentPosition,
                          width: 40,
                          height: 40,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                        // Marker restoran-restoran terdekat
                        ..._nearByRestaurants.map((resto) {
                          return Marker(
                            point: LatLng(resto['lat'], resto['lng']),
                            width: 45,
                            height: 45,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF4DD0E1),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.restaurant_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

          /// 2. TOP SEARCH BAR & MENU BUTTON
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.menu, color: Colors.black87),
                      onPressed: () {},
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      height: 55,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey.shade400),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: "Find bars and restaurants",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Icon(Icons.tune_rounded, color: Colors.grey.shade400),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          /// 3. TOMBOL SHORTCUT UNTUK MEMALIKKAN KAMERA KE LOKASI HP USER
          Positioned(
            right: 20,
            bottom:
                MediaQuery.of(context).size.height *
                0.38, // Berada tepat di atas sheet slide bawah
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                // Ketika ditekan, peta langsung pindah dan fokus ke lokasi terbaru HP user
                _mapController.move(_currentPosition, 16.0);
              },
              child: const Icon(Icons.gps_fixed, color: Color(0xFF4DD0E1)),
            ),
          ),

          /// 4. BOTTOM PANEL CARD ("NEAR YOU") - BISA DI-SLIDE ATAS/BAWAH
          DraggableScrollableSheet(
            initialChildSize: 0.35,
            minChildSize: 0.15,
            maxChildSize: 0.7,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  children: [
                    Center(
                      child: Container(
                        width: 50,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Near You",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 190,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _nearByRestaurants.length,
                        itemBuilder: (context, index) {
                          final resto = _nearByRestaurants[index];
                          return Container(
                            width: 190,
                            margin: const EdgeInsets.only(right: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F8FA),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  child: Image.network(
                                    resto['image']!,
                                    height: 110,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            Container(
                                              color: Colors.grey.shade300,
                                              height: 110,
                                            ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        resto['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF4DD0E1),
                                          fontSize: 14,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on,
                                            size: 12,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              resto['address']!,
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                                fontSize: 11,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
