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

  pickImage() async {
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        imageFile = File(picked.path);
      });
    }
  }

  uploadFood() async {
    final firestore = FirestoreService();

    String imageUrl = "https://picsum.photos/300";

    await firestore.addFood(
      name: nameController.text,
      category: categoryController.text,
      description: descController.text,
      image: imageUrl,
      rating: 4.5,
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Food')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Food Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: pickImage,
                child: const Text('Pick Image'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: uploadFood,
                child: const Text('Upload Food'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
