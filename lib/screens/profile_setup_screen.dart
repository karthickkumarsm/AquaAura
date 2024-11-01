import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'home_screen.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String userId;

  const ProfileSetupScreen({super.key, required this.userId});

  @override
  _ProfileSetupScreenState createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  String? username;
  String? profilePicUrl; // Local file path temporarily
  int? age;
  String? gender;
  double? waterGoal;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          profilePicUrl = image.path; // Store path temporarily
        });
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<String?> _uploadImageToFirebase() async {
    if (profilePicUrl != null) {
      try {
        File file = File(profilePicUrl!);
        String fileName = 'profile_pics/${widget.userId}/${DateTime.now().millisecondsSinceEpoch}';
        TaskSnapshot snapshot = await FirebaseStorage.instance.ref(fileName).putFile(file);
        return await snapshot.ref.getDownloadURL();
      } catch (e) {
        print('Error uploading image: $e');
        return null;
      }
    }
    return null;
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(
            child: Lottie.asset('assets/assets2.json'),
          );
        },
      );

      String? uploadedImageUrl = await _uploadImageToFirebase();

      UserModel user = UserModel(
        uid: widget.userId,
        username: username!,
        profilePicUrl: uploadedImageUrl ?? '',
        age: age!,
        gender: gender ?? 'Other',
        waterGoal: waterGoal ?? 2000,
      );

      FirestoreService firestoreService = FirestoreService();
      await firestoreService.saveUserProfile(user.uid, user.username, user.profilePicUrl, user.age, user.gender, user.waterGoal);

      Navigator.pop(context); // Close the Lottie animation dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(userId: widget.userId)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile Setup')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 50),
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: profilePicUrl != null ? FileImage(File(profilePicUrl!)) : null,
                    child: profilePicUrl == null ? const Icon(Icons.camera_alt, size: 50) : null,
                  ),
                ),
                const SizedBox(height: 50),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value!.isEmpty ? 'Please enter a username' : null,
                  onSaved: (value) => username = value,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Age'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Please enter your age' : null,
                  onSaved: (value) => age = int.parse(value!),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Gender'),
                  items: ['Male', 'Female', 'Other']
                      .map((gender) => DropdownMenuItem(value: gender, child: Text(gender)))
                      .toList(),
                  onChanged: (value) => gender = value,
                  validator: (value) => value == null ? 'Please select your gender' : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Daily Water Goal (ml)'),
                  keyboardType: TextInputType.number,
                  onSaved: (value) => waterGoal = double.parse(value!),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Okay',style: TextStyle(color: Colors.white),),
                  style: ButtonStyle(
                            backgroundColor:
                                MaterialStateProperty.all(Colors.blueGrey),
                            shape: MaterialStateProperty.all<
                                RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(0),
                              ),
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
