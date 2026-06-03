import 'dart:async';
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
  LatLng _currentPosition = const LatLng(
    -6.2000,
    106.8166,
  ); // Koordinat default Jakarta jika GPS belum siap
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _searchQuery = "";

  StreamSubscription<Position>? _positionStreamSubscription;

  /// MASTER DATA RESTORAN (Simulasi database lokal/API)
  final List<Map<String, dynamic>> _allFoodSpots = [
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
    {
      "name": "Kedai Kopi Dekat Sini",
      "address": "Sudirman Kav 21",
      "image":
          "https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=500",
      "lat": -6.1975,
      "lng": 106.8130,
    },
    {
      "name": "Seafood Spot Jauh",
      "address": "Ancol Beach Street",
      "image":
          "https://images.unsplash.com/photo-1519708227418-c8fd9a32b7a2?w=500",
      "lat": -6.1200,
      "lng": 106.8300,
    },
  ];

  /// VARIABEL UNTUK MENAMPUNG HASIL TRACKING GPS TERDEKAT DAN PENCARIAN
  List<Map<String, dynamic>> _nearByRestaurants = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionAndTrack();
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    _mapController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// FUNGSI UTAMA YANG SANGAT REAL-TIME (Mendukung GPS + Pencarian)
  void _updateNearbyFoodSpots(double userLat, double userLng) {
    List<Map<String, dynamic>> temporaryList = [];

    for (var spot in _allFoodSpots) {
      double distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        spot['lat'],
        spot['lng'],
      );

      // Batasi Radius: Hanya masukkan spot yang jaraknya kurang dari 3000 meter (3 KM)
      if (distanceInMeters <= 3000) {
        if (_searchQuery.isNotEmpty) {
          final restoName = spot['name'].toString().toLowerCase();
          final restoAddress = spot['address'].toString().toLowerCase();
          final query = _searchQuery.toLowerCase();

          if (!restoName.contains(query) && !restoAddress.contains(query)) {
            continue;
          }
        }

        Map<String, dynamic> spotWithDistance = Map.from(spot);
        spotWithDistance['distance'] = distanceInMeters;
        temporaryList.add(spotWithDistance);
      }
    }

    // Urutkan dari yang paling dekat ke yang paling jauh
    temporaryList.sort((a, b) => a['distance'].compareTo(b['distance']));

    setState(() {
      _nearByRestaurants = temporaryList;
    });
  }

  Future<void> _checkPermissionAndTrack() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackBar("Layanan lokasi (GPS) Anda dinonaktifkan.");
      setState(() => _isLoading = false);
      return;
    }

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

        _updateNearbyFoodSpots(
          initialPosition.latitude,
          initialPosition.longitude,
        );
        _mapController.move(_currentPosition, 15.0);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }

    // TRACKING REAL-TIME KETIKA USER BERJALAN ATAU PINDAH POSISI
    _positionStreamSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5, // Update setiap kali device bergeser 5 meter
          ),
        ).listen((Position position) {
          if (!mounted) return;

          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });

          _updateNearbyFoodSpots(position.latitude, position.longitude);

          // PERBAIKAN: Kamera peta sekarang otomatis mengikuti posisi USER, bukan melompat ke restoran terdekat
          _mapController.move(_currentPosition, 15.5);
        });
  }

  void _showSnackBar(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      return "${(meters / 1000).toStringAsFixed(1)} km";
    } else {
      return "${meters.toStringAsFixed(0)} m";
    }
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

                    /// MARKER PIN USER & RESTORAN
                    MarkerLayer(
                      markers: [
                        // Marker Posisi Pengguna (GPS) - Berwarna Biru
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
                        // Loop Marker Restoran Terdekat
                        ..._nearByRestaurants.map((resto) {
                          return Marker(
                            point: LatLng(resto['lat'], resto['lng']),
                            width: 60,
                            height: 60,
                            child: GestureDetector(
                              onTap: () {
                                // Fokuskan peta ke restoran yang diklik pin-nya
                                _mapController.move(
                                  LatLng(resto['lat'], resto['lng']),
                                  16.0,
                                );
                                _showSnackBar("Menuju ke: ${resto['name']}");
                              },
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ikon Dasar Pin Peta Berwarna Oranye
                                  const Icon(
                                    Icons.location_on,
                                    color: Colors.deepOrange,
                                    size: 55,
                                  ),
                                  // Logo Sendok & Garpu di Tengah Lingkaran Putih
                                  Positioned(
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.restaurant,
                                        color: Colors.deepOrange,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),

          /// 2. TOP SEARCH BAR (Pencarian Lokasi)
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
                              controller: _searchController,
                              maxLines:
                                  1, // Memastikan tidak terjadi assertion error multiline
                              onChanged: (value) {
                                _searchQuery = value;
                                _updateNearbyFoodSpots(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                );
                              },
                              decoration: InputDecoration(
                                hintText: "Find recommendations near you",
                                hintStyle: TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 15,
                                ),
                                border: InputBorder.none,
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          _searchController.clear();
                                          setState(() {
                                            _searchQuery = "";
                                          });
                                          _updateNearbyFoodSpots(
                                            _currentPosition.latitude,
                                            _currentPosition.longitude,
                                          );
                                        },
                                      )
                                    : null,
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

          /// 3. TOMBOL LOCK LOKASI GPS (Kembali mengunci ke posisi pengguna)
          Positioned(
            right: 20,
            bottom: MediaQuery.of(context).size.height * 0.38,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                _mapController.move(_currentPosition, 16.0);
              },
              child: const Icon(Icons.gps_fixed, color: Color(0xFF4DD0E1)),
            ),
          ),

          /// 4. BOTTOM PANEL CARD (Daftar Restoran Horizontal)
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Near You",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          "${_nearByRestaurants.length} tempat ditemukan",
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _nearByRestaurants.isEmpty
                        ? SizedBox(
                            height: 190,
                            child: Center(
                              child: Text(
                                _searchQuery.isEmpty
                                    ? "Tidak ada kedai makanan terdekat dalam radius 3 KM."
                                    : "Rekomendasi '$_searchQuery' tidak ditemukan di sekitar koordinat GPS Anda.",
                                style: TextStyle(color: Colors.grey.shade500),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 210,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _nearByRestaurants.length,
                              itemBuilder: (context, index) {
                                final resto = _nearByRestaurants[index];
                                return GestureDetector(
                                  onTap: () {
                                    // Fokuskan peta ke restoran saat kartu di bawah diklik
                                    _mapController.move(
                                      LatLng(resto['lat'], resto['lng']),
                                      16.0,
                                    );
                                  },
                                  child: Container(
                                    width: 190,
                                    margin: const EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF7F8FA),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Stack(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                    top: Radius.circular(20),
                                                  ),
                                              child: Image.network(
                                                resto['image']!,
                                                height: 110,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (
                                                      context,
                                                      error,
                                                      stackTrace,
                                                    ) => Container(
                                                      color:
                                                          Colors.grey.shade300,
                                                      height: 110,
                                                    ),
                                              ),
                                            ),
                                            Positioned(
                                              top: 8,
                                              right: 8,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 4,
                                                    ),
                                                decoration: BoxDecoration(
                                                  color: Colors.black
                                                      .withOpacity(0.7),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  _formatDistance(
                                                    resto['distance'],
                                                  ),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
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
                                                        color: Colors
                                                            .grey
                                                            .shade500,
                                                        fontSize: 11,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
