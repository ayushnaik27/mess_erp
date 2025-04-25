import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/features/committee/models/committee_user.dart';

class CommitteeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<CommitteeUser?> getCommitteeUser(String email) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('loginCredentials')
          .doc('roles')
          .collection('committee')
          .doc(email)
          .get();

      if (snapshot.exists) {
        return CommitteeUser(
          name: snapshot.data()?['name'] ?? '',
          username: snapshot.data()?['email'] ?? '',
          password: snapshot.data()?['password'] ?? '',
          role: snapshot.data()?['role'] ?? '',
          email: snapshot.data()?['email'] ?? '',
        );
      }
      return null;
    } catch (e) {
      print('Error fetching committee user: $e');
      return null;
    }
  }
}
