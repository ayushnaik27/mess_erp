import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/committee/models/weekly_menu_model.dart';

class MessMenuRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  Future<WeeklyMenu?> getWeeklyMenu(String hostelId) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(hostelId)
          .collection(FirestoreConstants.hostelMess)
          .doc(FirestoreConstants.messMenu)
          .get();

      if (snapshot.exists && snapshot.data() != null) {
        _logger.i('Retrieved mess menu for hostel: $hostelId');
        return WeeklyMenu.fromJson(snapshot.data()!);
      }
      _logger.w('No mess menu found for hostel: $hostelId');
      return null;
    } catch (e) {
      _logger.e('Error fetching weekly menu: $e');
      return null;
    }
  }

  Future<void> updateWeeklyMenu(WeeklyMenu menu) async {
    try {
      _logger.i('Updating mess menu for hostel: ${menu.hostelId}');

      await _firestore
          .collection(FirestoreConstants.hostels)
          .doc(menu.hostelId)
          .collection(FirestoreConstants.hostelMess)
          .doc(FirestoreConstants.messMenu)
          .set(menu.toJson());

      _logger.i('Successfully updated mess menu');
    } catch (e) {
      _logger.e('Error updating weekly menu: $e');
      throw e;
    }
  }
}
