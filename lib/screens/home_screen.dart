import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'calendar_screen.dart';
import '../models/child_profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;

  ChildProfile? profile;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<void> _captureImage() async {
    final XFile? picked = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 75,
    );
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(context);
                _captureImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _submitProfile() {
    if (_formKey.currentState!.validate()) {
      profile = ChildProfile(
        name: _nameController.text.trim(),
        imagePath: _imageFile?.path,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => CalendarScreen(profile: profile!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool hasCustomImage = _imageFile != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Profile'),
        backgroundColor: Colors.deepOrange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Form(
              key: _formKey,
              child: TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Enter your name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _showImageSourceDialog,
              child: CircleAvatar(
                radius: 60,
                backgroundImage: hasCustomImage
                    ? FileImage(_imageFile!)
                    : const AssetImage('assets/images/placeholder.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 10),
            const Text('Tap the image to take or select a photo'),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _submitProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
              ),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
