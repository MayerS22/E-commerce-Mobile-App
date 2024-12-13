import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String name;
  final String email;
  final DateTime birthday;

  UserProfile({required this.name, required this.email, required this.birthday});

  // Convert Firestore data to a UserProfile object
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      name: data['name'],
      email: data['email'],
      birthday: (data['birthday'] as Timestamp).toDate(),
    );
  }

  // Convert a UserProfile object to a Firestore-friendly map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'birthday': Timestamp.fromDate(birthday), // Convert DateTime to Firestore Timestamp
    };
  }
}
