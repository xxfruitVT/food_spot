import 'dart:convert'; // Ditambahkan untuk konversi Base64
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  File? imageFile;
  String? _photoBase64; // Menyimpan string base64 dari database
  final picker = ImagePicker();

  bool _isEditingMode = false;
  bool _isLoading = true;

  // Controller untuk mengedit data text field
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _emailController.text = user?.email ?? "";
    _loadUserData();

    _nameController.addListener(() {
      setState(() {});
    });
    _usernameController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  /// FUNGSI MENGAMBIL DATA DARI FIRESTORE (TERMASUK FOTO)
  Future<void> _loadUserData() async {
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(user!.uid)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        _nameController.text =
            data['fullName'] ?? user?.displayName ?? "Mark Johnson";
        _usernameController.text = data['username'] ?? "@markjohnson";
        _bioController.text =
            data['bio'] ??
            "Food lover | Traveler | Blogger 🩵\nSharing delicious experiences and recipes ❤️🔥";

        // Ambil data foto yang tersimpan dalam bentuk string Base64
        _photoBase64 = data['photoUrl'];
      } else {
        _nameController.text = user?.displayName ?? "Mark Johnson";
        _usernameController.text = "@markjohnson";
        _bioController.text =
            "Food lover | Traveler | Blogger 🩵\nSharing delicious experiences and recipes ❤️🔥";
      }
    } catch (e) {
      _showSnackBar("Gagal memuat data profil: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// FUNGSI MENYIMPAN DATA DATA + FOTO KE FIRESTORE
  Future<void> _saveUserData() async {
    if (user == null) return;

    setState(() => _isLoading = true);

    try {
      await user!.updateDisplayName(_nameController.text);

      // Jika ada file gambar baru yang dipilih secara lokal, konversikan dulu ke Base64 String
      if (imageFile != null) {
        List<int> imageBytes = await imageFile!.readAsBytes();
        _photoBase64 = base64Encode(imageBytes);
      }

      // Simpan semua data secara sinkron ke Cloud Firestore
      await _firestore.collection('users').doc(user!.uid).set({
        'fullName': _nameController.text,
        'username': _usernameController.text,
        'email': _emailController.text,
        'bio': _bioController.text,
        'photoUrl': _photoBase64, // Menyimpan string gambar ke database
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _showSnackBar("Profile updated successfully!");
      setState(() => _isEditingMode = false);
    } catch (e) {
      _showSnackBar("Gagal menyimpan perubahan: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await picker.pickImage(
      source: source,
      imageQuality: 60,
    ); // image quality dikurangi sedikit agar ukuran string database ringan
    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  void showPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Change Profile Photo",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              ListTile(
                leading: const Icon(Icons.camera_alt, color: Color(0xFF4DD0E1)),
                title: const Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF4DD0E1),
                ),
                title: const Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// HELPER UNTUK MENAMPILKAN GAMBAR (Lokal -> Database -> Placeholder)
  ImageProvider _getProfileImage() {
    if (imageFile != null) {
      return FileImage(
        imageFile!,
      ); // Prioritas 1: Gambar baru yang baru saja di-pick user
    } else if (_photoBase64 != null && _photoBase64!.isNotEmpty) {
      return MemoryImage(
        base64Decode(_photoBase64!),
      ); // Prioritas 2: Gambar lama dari Firestore yang di-decode kembali
    } else {
      return const NetworkImage(
        "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500", // Pasrah ke default jika kosong total
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF4DD0E1)),
              )
            : Column(
                children: [
                  /// HEADER BAR
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const SizedBox(width: 48),
                        Expanded(
                          child: Center(
                            child: Text(
                              _isEditingMode
                                  ? "User personalization"
                                  : "Profile",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        _isEditingMode
                            ? const SizedBox(width: 48)
                            : IconButton(
                                icon: const Icon(
                                  Icons.settings_outlined,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() => _isEditingMode = true);
                                },
                              ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        children: [
                          const SizedBox(height: 10),

                          /// AVATAR
                          Center(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: showPicker,
                                  child: Container(
                                    height: 110,
                                    width: 110,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.08),
                                          blurRadius: 15,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                      image: DecorationImage(
                                        image:
                                            _getProfileImage(), // Memanggil fungsi pengecekan gambar pintar
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                const Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Icon(
                                    Icons.circle,
                                    size: 24,
                                    color: Color(0xFF4DD0E1),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// TEXT NAMA & USERNAME UTAMA
                          Text(
                            _nameController.text.isEmpty
                                ? "No Name"
                                : _nameController.text,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _usernameController.text.isEmpty
                                ? "@username"
                                : _usernameController.text,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.grey.shade400,
                            ),
                          ),

                          const SizedBox(height: 32),

                          /// FORM ENTRIES
                          _buildInputField(
                            label: "Full Name",
                            controller: _nameController,
                            enabled: _isEditingMode,
                            showEditButton: !_isEditingMode,
                            onEditPressed: () {
                              setState(() => _isEditingMode = true);
                            },
                          ),
                          const SizedBox(height: 20),

                          _buildInputField(
                            label: "Username",
                            controller: _usernameController,
                            enabled: _isEditingMode,
                          ),
                          const SizedBox(height: 20),

                          if (!_isEditingMode) ...[
                            _buildInputField(
                              label: "Email",
                              controller: _emailController,
                              enabled: false,
                            ),
                            const SizedBox(height: 20),
                          ],

                          _buildInputField(
                            label: "Bio",
                            controller: _bioController,
                            enabled: _isEditingMode,
                            isBio: true,
                          ),

                          const SizedBox(height: 40),

                          /// TOMBOL SAVE / LOGOUT
                          GestureDetector(
                            onTap: () async {
                              if (_isEditingMode) {
                                _saveUserData();
                              } else {
                                await FirebaseAuth.instance.signOut();
                                if (!mounted) return;
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                  (route) => false,
                                );
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                gradient: LinearGradient(
                                  colors: _isEditingMode
                                      ? [
                                          const Color(0xFFF77062),
                                          const Color(0xFFFE5196),
                                        ]
                                      : [
                                          const Color(0xFF00E5FF),
                                          const Color(0xFF1976D2),
                                        ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        (_isEditingMode
                                                ? Colors.red
                                                : Colors.cyan)
                                            .withOpacity(0.25),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  _isEditingMode ? "Save Changes" : "Log Out",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required bool enabled,
    bool isBio = false,
    bool showEditButton = false,
    VoidCallback? onEditPressed,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            TextField(
              controller: controller,
              enabled: enabled,
              maxLines: isBio ? null : 1,
              keyboardType: isBio
                  ? TextInputType.multiline
                  : TextInputType.text,
              obscureText: false,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF7F8FA),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF4DD0E1),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            if (showEditButton)
              Positioned(
                right: 8,
                child: TextButton.icon(
                  onPressed: onEditPressed,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xEFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                    color: Color(0xFF4DD0E1),
                  ),
                  label: const Text(
                    "Edit",
                    style: TextStyle(
                      color: Color(0xFF4DD0E1),
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
