import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';
import 'package:mess_erp/features/student/models/extra_item_model.dart';

class ExtraItemsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AppLogger _logger = AppLogger();

  Future<List<ExtraItem>> getExtraItems() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await _firestore.collection(FirestoreConstants.extraItems).get();

      return snapshot.docs.map((doc) {
        return ExtraItem.fromMap(doc.data(), doc.id);
      }).toList();
    } catch (e) {
      _logger.e('Error fetching extra items', error: e);
      return [];
    }
  }

  Future<bool> addExtraItemRequest({
    required String rollNumber,
    required String itemName,
    required int quantity,
    required double amount,
  }) async {
    try {
      await _firestore
          .collection('${FirestoreConstants.extraItems}_requests')
          .add({
        FirestoreConstants.rollNumber: rollNumber,
        'itemName': itemName,
        'quantity': quantity,
        'amount': amount,
        FirestoreConstants.timestamp: DateTime.now(),
      });

      _logger
          .i('Extra item request added for $rollNumber: $itemName ($quantity)');
      return true;
    } catch (e) {
      _logger.e('Error adding extra item request', error: e);
      return false;
    }
  }

  // For admin functionality: Add a new extra item
  Future<bool> addExtraItem(String name, double price) async {
    try {
      await _firestore.collection(FirestoreConstants.extraItems).add({
        FirestoreConstants.name: name,
        'price': price,
      });

      _logger.i('Extra item added: $name at price $price');
      return true;
    } catch (e) {
      _logger.e('Error adding extra item', error: e);
      return false;
    }
  }

  // For admin functionality: Edit an existing extra item
  Future<bool> editExtraItem(String itemId, String name, double price) async {
    try {
      await _firestore
          .collection(FirestoreConstants.extraItems)
          .doc(itemId)
          .update({
        FirestoreConstants.name: name,
        'price': price,
      });

      _logger.i('Extra item updated: $name at price $price');
      return true;
    } catch (e) {
      _logger.e('Error updating extra item', error: e);
      return false;
    }
  }

  // For admin functionality: Delete an extra item
  Future<bool> deleteExtraItem(String itemId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.extraItems)
          .doc(itemId)
          .delete();

      _logger.i('Extra item deleted: $itemId');
      return true;
    } catch (e) {
      _logger.e('Error deleting extra item', error: e);
      return false;
    }
  }

  // For admin functionality: Get all extra item requests
  Stream<List<Map<String, dynamic>>> getExtraItemRequestsStream() {
    return _firestore
        .collection(FirestoreConstants.extraItems + '_requests')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          FirestoreConstants.rollNumber:
              data[FirestoreConstants.rollNumber] ?? '',
          'itemName': data['itemName'] ?? '',
          'quantity': data['quantity'] ?? 0,
          'amount': data['amount'] ?? 0.0,
          'timestamp':
              data[FirestoreConstants.timestamp]?.toDate() ?? DateTime.now(),
        };
      }).toList();
    });
  }

  // For admin functionality: Delete an extra item request
  Future<bool> deleteExtraItemRequest(String requestId) async {
    try {
      await _firestore
          .collection(FirestoreConstants.extraItems + '_requests')
          .doc(requestId)
          .delete();

      _logger.i('Extra item request deleted: $requestId');
      return true;
    } catch (e) {
      _logger.e('Error deleting extra item request', error: e);
      return false;
    }
  }

  // For admin functionality: Approve an extra item request
  Future<bool> approveExtraItemRequest({
    required String requestId,
    required String rollNumber,
    required String itemName,
    required int quantity,
    required double amount,
  }) async {
    try {
      // Delete the request
      await deleteExtraItemRequest(requestId);

      // Add to student's bill
      await addBillForStudent(rollNumber, DateTime.now(), itemName, amount);

      _logger.i('Extra item request approved for $rollNumber: $itemName');
      return true;
    } catch (e) {
      _logger.e('Error approving extra item request', error: e);
      return false;
    }
  }

  // Add to student's bill
  Future<void> addBillForStudent(
      String rollNumber, DateTime date, String itemName, double amount) async {
    try {
      CollectionReference studentsBillCollection = _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.students)
          .doc(rollNumber)
          .collection(FirestoreConstants.bills);

      String docId = DateFormat('dd-MM-yyyy').format(date);

      await studentsBillCollection.doc(docId).set({
        'date': DateTime.now(),
        'year': DateTime.now().year.toString(),
        'month': DateTime.now().month.toString(),
        'items': FieldValue.arrayUnion([
          {
            'item': itemName,
            'amount': amount,
          }
        ]),
      }, SetOptions(merge: true));

      // Update the extra amount total
      await _firestore
          .collection(FirestoreConstants.extraItems + '_amount')
          .doc('extra_amount')
          .set({
        'amount': FieldValue.increment(amount),
      }, SetOptions(merge: true));

      _logger.i('Bill added for student $rollNumber: $itemName ($amount)');
    } catch (e) {
      _logger.e('Error adding bill for student', error: e);
      throw e;
    }
  }
}
