import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/firestore_service.dart';

class AddFoodScreen extends StatefulWidget {
  const AddFoodScreen({super.key});

  @override
  State<AddFoodScreen> createState() => _AddFoodScreenState();
}

class _AddFoodScreenState extends State<AddFoodScreen> {
  /// CONTROLLER
  final nameController = TextEditingController();
  final descController = TextEditingController();

  /// IMAGE
  File? imageFile;

  final picker = ImagePicker();

  /// LOADING
  bool isLoading = false;

  /// CATEGORY
  String selectedCategory = "Burger";

  final List<String> categories = [
    "Burger",
    "Pizza",
    "Drink",
    "Rice",
    "Snack",
    "Noodle",
  ];

  /// PICK IMAGE
  pickImage(ImageSource source) async {
    final picked = await picker.pickImage(source: source, imageQuality: 80);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  /// BOTTOM SHEET
  showImagePicker() {
    showModalBottomSheet(
      context: context,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),

      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              const Text(
                "Choose Image",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 25),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

                children: [
                  /// CAMERA
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.camera);
                    },

                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.orange,
                            size: 35,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Camera",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),

                  /// GALLERY
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      pickImage(ImageSource.gallery);
                    },

                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(0.1),

                            shape: BoxShape.circle,
                          ),

                          child: const Icon(
                            Icons.photo_library,
                            color: Colors.orange,
                            size: 35,
                          ),
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          "Gallery",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }

  /// UPLOAD FOOD
  uploadFood() async {
    /// VALIDATION
    if (nameController.text.isEmpty || descController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final firestore = FirestoreService();

      /// TEMP IMAGE URL
      String imageUrl = "https://picsum.photos/300";

      await firestore.addFood(
        name: nameController.text.trim(),
        category: selectedCategory,
        description: descController.text.trim(),
        image: imageUrl,
        rating: 4.5,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Food uploaded successfully"),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,

        title: const Text(
          "Add Food",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            /// HEADER
            const Text(
              "Create New Food",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            const Text(
              "Add delicious food to your collection 🍔",
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            /// MAIN CARD
            Container(
              padding: const EdgeInsets.all(24),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(28),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),

                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  /// IMAGE PICKER
                  GestureDetector(
                    onTap: showImagePicker,

                    child: Container(
                      height: 220,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(22),

                        border: Border.all(color: Colors.grey.shade300),
                      ),

                      child: imageFile != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(22),

                              child: Image.file(imageFile!, fit: BoxFit.cover),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,

                              children: [
                                Container(
                                  padding: const EdgeInsets.all(18),

                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.1),

                                    shape: BoxShape.circle,
                                  ),

                                  child: const Icon(
                                    Icons.image_outlined,
                                    size: 45,
                                    color: Colors.orange,
                                  ),
                                ),

                                const SizedBox(height: 15),

                                const Text(
                                  "Tap to Upload Image",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 6),

                                const Text(
                                  "Camera or Gallery",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  /// FOOD NAME
                  TextField(
                    controller: nameController,

                    decoration: InputDecoration(
                      labelText: "Food Name",
                      hintText: "Enter food name",

                      prefixIcon: const Icon(Icons.fastfood_rounded),

                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// CATEGORY
                  DropdownButtonFormField(
                    value: selectedCategory,

                    items: categories.map((e) {
                      return DropdownMenuItem(value: e, child: Text(e));
                    }).toList(),

                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },

                    decoration: InputDecoration(
                      labelText: "Category",

                      prefixIcon: const Icon(Icons.category_rounded),

                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// DESCRIPTION
                  TextField(
                    controller: descController,
                    maxLines: 5,

                    decoration: InputDecoration(
                      labelText: "Description",
                      hintText: "Write food description...",

                      alignLabelWithHint: true,

                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(bottom: 80),

                        child: Icon(Icons.description_outlined),
                      ),

                      filled: true,
                      fillColor: Colors.grey.shade100,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  /// BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 58,

                    child: ElevatedButton.icon(
                      onPressed: isLoading ? null : uploadFood,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,

                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),

                      icon: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,

                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.cloud_upload_rounded),

                      label: Text(
                        isLoading ? "Uploading..." : "Upload Food",

                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
