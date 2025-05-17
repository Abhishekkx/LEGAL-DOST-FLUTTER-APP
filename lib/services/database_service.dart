import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUserRole(String uid, String role) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'role': role,
        'createdAt': Timestamp.now(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving user role: $e');
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.get('role') as String? : null;
    } catch (e) {
      print('Error getting user role: $e');
      return null;
    }
  }

  Future<void> saveLawyerRegistrationStatus(String uid, bool isRegistered) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'isLawyerRegistered': isRegistered,
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving lawyer registration status: $e');
    }
  }

  Future<bool?> getLawyerRegistrationStatus(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.get('isLawyerRegistered') as bool? : false;
    } catch (e) {
      print('Error getting lawyer registration status: $e');
      return false;
    }
  }

  Future<void> saveLawyerProfile(String uid, Map<String, dynamic> profileData) async {
    try {
      await _firestore.collection('lawyers').doc(uid).set(profileData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error saving lawyer profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getLawyerProfile(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('lawyers').doc(uid).get();
      return doc.exists ? doc.data() as Map<String, dynamic>? : null;
    } catch (e) {
      print('Error getting lawyer profile: $e');
      return null;
    }
  }

  Future<void> resetUserData(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).delete();
      await _firestore.collection('lawyers').doc(uid).delete();
    } catch (e) {
      print('Error resetting user data: $e');
    }
  }
}