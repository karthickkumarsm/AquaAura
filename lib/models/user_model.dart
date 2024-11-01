class UserModel {
  String uid;
  String username;
  String profilePicUrl;
  int age;
  String gender;
  double waterGoal;

  UserModel({
    required this.uid,
    required this.username,
    required this.profilePicUrl,
    required this.age,
    required this.gender,
    required this.waterGoal,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'profilePicUrl': profilePicUrl,
      'age': age,
      'gender': gender,
      'waterGoal': waterGoal,
    };
  }

  static UserModel fromMap(String uid, Map<String, dynamic> map) {
    return UserModel(
      uid: uid,
      username: map['username'],
      profilePicUrl: map['profilePicUrl'],
      age: map['age'],
      gender: map['gender'],
      waterGoal: map['waterGoal'],
    );
  }
}
