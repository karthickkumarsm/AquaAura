import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:water_reminder_app/services/firebase_auth_service.dart';
import '../services/firestore_service.dart';
import '../models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  final String userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuthService _authService = FirebaseAuthService();
  UserModel? user;
  String? newGoal;
  String? profilePicUrl;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    user = await _firestoreService.getUser(widget.userId);
    setState(() {});
  }

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

  Future<void> updateGoal() async {
    if (user != null && newGoal != null) {
      try {
        user!.waterGoal = double.parse(newGoal!);
        await _firestoreService.updateUser(user!);
        print("Water goal updated successfully.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(userId: widget.userId),
          ),
        );
      } catch (e) {
        print("Error updating water goal: $e");
      }
    } else {
      print("User or new goal is null.");
    }
  }

 Future<void> signOut() async {
    await _authService.signOut();
    if (mounted) {
      setState(() {
        user = null; // Clear user data
      });
      Navigator.pushReplacementNamed(context, '/login');
      AwesomeNotifications().cancelAll();
    }
  }

 Future<void> deleteUser() async {
  // Show a confirmation dialog
  bool? confirmDelete = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text('Are you sure you want to delete your account? This action cannot be undone.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false), // Dismiss with 'No'
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true), // Dismiss with 'Yes'
            child: const Text('Yes',style: TextStyle(color: Colors.red),),
          ),
        ],
      );
    },
  );

  // If the user confirmed the deletion
  if (confirmDelete == true) {
    try {
      print("deleting user");
      await _firestoreService.deleteUser(widget.userId);
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await reauthenticateUser();
        await user.delete();
        AwesomeNotifications().cancelAll();
         await _authService.signOut();

      }
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print("An error occurred while deleting the account: $e");
    }
  } else {
    print("User canceled account deletion.");
  }
}

Future<void> reauthenticateUser() async {
  User? user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    await user.reauthenticateWithCredential(credential);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings'),
      ),
      body: user == null
          ? Center(child: Lottie.asset('assets/assets2.json'))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                    GestureDetector(
                    onTap: () async {
                      bool? confirmChange = await showDialog<bool>(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                        title: const Text('Change Profile Picture'),
                        content: const Text('Do you want to change your profile picture?'),
                        actions: <Widget>[
                          TextButton(
                          onPressed: () => Navigator.of(context).pop(false), // Dismiss with 'No'
                          child: const Text('No'),
                          ),
                          TextButton(
                          onPressed: () => Navigator.of(context).pop(true), // Dismiss with 'Yes'
                          child: const Text('Yes', style: TextStyle(color: Colors.blue)),
                          ),
                        ],
                        );
                      },
                      );

                        if (confirmChange == true) {
                        setState(() {
                          profilePicUrl = null; // Clear the current profile picture
                        });
                        
                        await _pickImage(); // Assuming this function picks the image

                        // Show the loading dialog with Lottie animation
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) {
                            return Center(
                              child: Lottie.asset('assets/assets2.json'),
                            );
                          },
                        );

                        // Start the image upload
                        String? downloadUrl = await _uploadImageToFirebase(); // Your image upload function

                        // Dismiss the dialog after the upload completes
                        Navigator.of(context).pop(); // Dismiss the loading dialog

                        if (downloadUrl != null) {
                          setState(() {
                            user!.profilePicUrl = downloadUrl; // Update the user's profile picture URL
                          });
                          await _firestoreService.updateUser(user!); // Update the user data in Firestore
                          print("Profile picture updated successfully.");
                        } else {
                          print("Failed to upload profile picture.");
                        }
                      } else {
                        print("User canceled profile picture change.");
                      }
                    },
                    child: CircleAvatar(
                      radius: 75,
                      backgroundImage: profilePicUrl != null
                        ? FileImage(File(profilePicUrl!))
                        : (user!.profilePicUrl != null ? NetworkImage(user!.profilePicUrl!) : null),
                      child: profilePicUrl == null && user!.profilePicUrl == null
                        ? const Icon(Icons.camera_alt, size: 50)
                        : null,
                    ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Name: ${user!.username}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Text(
                    'Age: ${user!.age}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Text(
                    'Gender: ${user!.gender}',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  Text(
                    'Daily Water Goal: ${user!.waterGoal} ml',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          decoration: const InputDecoration(
                            labelText: 'Update your Water Goal (ml)',
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue)),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) => newGoal = value,
                        ),
                      ),
                      const SizedBox(width: 10), // Add some space between the TextFormField and the button
                      ElevatedButton(
                        onPressed: updateGoal,
                        child: const Text(
                          'Update Goal',
                          style: TextStyle(color: Colors.white),
                        ),
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
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: signOut,
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.orange),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                    child: Text('Logout account',style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.red),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                    ),
                    onPressed: deleteUser,
                    child: Text('Delete Account',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }
}