import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class Grievance {
  final String grievanceId;
  final String studentRollNo;
  final String name;
  final DateTime dateOfFiling;
  final String grievanceTitle;
  final String grievanceDesc;
  final String fileUpload;
  String status;
  String assignedTo;
  final List<Map<String, dynamic>> history;
  int reminderCount = 0;

  Grievance({
    required this.grievanceId,
    required this.studentRollNo,
    required this.name,
    required this.dateOfFiling,
    required this.grievanceTitle,
    required this.grievanceDesc,
    required this.fileUpload,
    required this.status,
    required this.assignedTo,
    required this.history,
    required this.reminderCount,
  });

  Grievance.fromMap(Map<String, dynamic> data)
      : grievanceId = data['grievanceId'],
        studentRollNo = data['studentRollNo'],
        name = data['name'],
        dateOfFiling = data['dateOfFiling'].toDate(),
        grievanceTitle = data['grievanceTitle'],
        grievanceDesc = data['grievanceDesc'],
        fileUpload = data['fileUpload'],
        status = data['status'],
        assignedTo = data['assignedTo'],
        history = List<Map<String, dynamic>>.from(data['history']),
        reminderCount = data['reminderCount'] ?? 0;

  Map<String, dynamic> toMap() {
    return {
      'grievanceId': grievanceId,
      'studentRollNo': studentRollNo,
      'name': name,
      'dateOfFiling': dateOfFiling,
      'grievanceTitle': grievanceTitle,
      'grievanceDesc': grievanceDesc,
      'fileUpload': fileUpload,
      'status': status,
      'assignedTo': assignedTo,
      'history': history,
      'reminderCount': reminderCount,
    };
  }
}

class GrievanceProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'grievances';
  List<Grievance> _grievances = [];

  List<Grievance> get grievances => _grievances;

  Future<void> fetchGrievancesForStudents(String studentRollNo) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(_collection)
          .where('studentRollNo', isEqualTo: studentRollNo)
          .get();
      _grievances = querySnapshot.docs
          .map((doc) => Grievance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<List<Grievance>> fetchAssignedGrievances(String assignedTo) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection(_collection)
          .where('assignedTo', isEqualTo: assignedTo)
          .get();
      return querySnapshot.docs
          .map((doc) => Grievance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

  Future<void> resolveGrievanceWithRemarks(
      String grievanceId, String remarks, String updatedBy) async {
    try {
      await _db.collection(_collection).doc(grievanceId).update({
        'assignedTo': 'student',
        'status': 'resolved',
        'history': FieldValue.arrayUnion([
          {
            'updatedBy': updatedBy,
            'date': DateTime.now(),
            'action': 'Resolved',
            'remarks': remarks,
          }
        ]),
      });
      _grievances
          .firstWhere((grievance) => grievance.grievanceId == grievanceId)
          .status = 'resolved';
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> markInProcessGrievanceWithRemarks(
      String grievanceId, String remarks, String updatedBy) async {
    try {
      await _db.collection(_collection).doc(grievanceId).update({
        'status': 'in process',
        'history': FieldValue.arrayUnion([
          {
            'updatedBy': updatedBy,
            'date': DateTime.now(),
            'action': 'Marked in process',
            'remarks': remarks,
          }
        ]),
      });
      _grievances
          .firstWhere((grievance) => grievance.grievanceId == grievanceId)
          .status = 'in process';
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> forwardGrievanceWithRemarks(String grievanceId, String remarks,
      String forwardTo, String updatedBy) async {
    try {
      forwardTo = forwardTo.toLowerCase();
      await _db.collection(_collection).doc(grievanceId).update({
        'assignedTo': forwardTo,
        'history': FieldValue.arrayUnion([
          {
            'updatedBy': updatedBy,
            'date': DateTime.now(),
            'action': 'Forwarded to $forwardTo',
            'remarks': remarks,
          }
        ]),
      });
      _grievances
          .firstWhere((grievance) => grievance.grievanceId == grievanceId)
          .assignedTo = forwardTo;
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fileGrievance(Grievance grievance) async {
    try {
      await _db
          .collection(_collection)
          .doc(grievance.grievanceId)
          .set(grievance.toMap());
      _grievances.add(grievance);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> autoDeleteTwoMonthsOldGrievances() async {
    print('Auto deleting old grievances');
    try {
      QuerySnapshot querySnapshot = await _db.collection(_collection).get();
      List<Grievance> grievances = querySnapshot.docs
          .map((doc) => Grievance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      DateTime twoMonthsAgo = DateTime.now().subtract(const Duration(days: 60));
      List<Grievance> oldGrievances = grievances
          .where((grievance) => grievance.dateOfFiling.isBefore(twoMonthsAgo))
          .toList();
      for (Grievance grievance in oldGrievances) {
        await _db.collection(_collection).doc(grievance.grievanceId).delete();
        _grievances.remove(grievance);
      }
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> fetchAllGrievances() async {
    await autoDeleteTwoMonthsOldGrievances();
    try {
      QuerySnapshot querySnapshot = await _db.collection(_collection).get();
      _grievances = querySnapshot.docs
          .map((doc) => Grievance.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }
}
