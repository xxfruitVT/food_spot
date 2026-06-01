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
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final descController = TextEditingController();

  File? imageFile;

  final picker = ImagePicker();

  bool isLoading = false;

  pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  uploadFood() async {
    setState(() {
      isLoading = true;
    });

    try {
      final firestore = FirestoreService();

      String imageUrl = "https://picsum.photos/300";

      await firestore.addFood(
        name: nameController.text.trim(),
        category: categoryController.text.trim(),
        description: descController.text.trim(),
        image: imageUrl,
        rating: 4.5,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Food uploaded successfully'),
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
          'Add Food',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Create New Food',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add delicious food information to your collection',
              style: TextStyle(color: Colors.grey, fontSize: 15),
            ),

            const SizedBox(height: 30),

            // Main Card
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
                  // Image Picker
                  GestureDetector(
                    onTap: pickImage,
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
                                  'Tap to Upload Image',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Text(
                                  'PNG, JPG or JPEG',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Food Name
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Food Name',
                      hintText: 'Enter food name',
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

                  // Category
                  TextField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: 'Category',
                      hintText: 'Enter category',
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

                  // Description
                  TextField(
                    controller: descController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      hintText: 'Write food description...',
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

                  // Upload Button
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
                        isLoading ? 'Uploading...' : 'Upload Food',
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
