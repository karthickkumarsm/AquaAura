import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> createUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).set(user.toMap());
  }

  Future<bool> isUserProfileSet(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    return doc.exists; // Return true if profile exists
  }

  Future<void> saveUserProfile(String userId, String username, String profilePicUrl, int age, String gender, double waterGoal) async {
    UserModel userModel = UserModel(
      uid: userId,
      username: username,
      profilePicUrl: profilePicUrl,
      age: age,
      gender: gender,
      waterGoal: waterGoal,
    );
    await _db.collection('users').doc(userId).set(userModel.toMap());
  }

  Future<UserModel?> getUser(String userId) async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromMap(userId, doc.data() as Map<String, dynamic>);
    } else {
      return null; // Return null if the user does not exist
    }
  }

  Future<void> addWaterIntake(String userId, double amount) async {
    await _db.collection('users').doc(userId).collection('waterIntake').add({
      'amount': amount,
      'date': Timestamp.now(),
    });
  }

  Future<List<Map<String, dynamic>>> getWaterIntakeHistory(String userId) async {
    QuerySnapshot querySnapshot = await _db
        .collection('users')
        .doc(userId)
        .collection('waterIntake')
        .orderBy('date', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
  }

  Future<void> deleteLatestIntakeEntry(String userId, double amount) async {
  QuerySnapshot snapshot = await FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('waterIntake')
      .where('amount', isEqualTo: amount)
      .orderBy('date', descending: true)
      .limit(1)
      .get();

  if (snapshot.docs.isNotEmpty) {
    await snapshot.docs.first.reference.delete();
  }
}


  Future<void> updateUser(UserModel user) async {
    await _db.collection('users').doc(user.uid).update(user.toMap());
  }

  Future<void> deleteUser(String userId) async {
    await _db.collection('users').doc(userId).delete();
  }
}
