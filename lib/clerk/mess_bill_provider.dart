import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;

import '../providers/announcement_provider.dart';

class MessBill {
  final String rollNumber;
  final num totalDiets;
  final num totalExtra;
  final num fine;
  final num totalAmount;
  List<Map<String, dynamic>> extraList;
  String? month;

  MessBill({
    required this.rollNumber,
    required this.totalDiets,
    required this.totalExtra,
    required this.fine,
    required this.totalAmount,
    required this.extraList,
    this.month,
  });
}

class MessBillProvider with ChangeNotifier {
  List<MessBill> _messBills = [];
  List<MessBill> get messBills => _messBills;

  bool isMonthInSemester(
      String yearMonth, String semester, String requiredYear) {
    // Extract the year and month from the month string
    List<String> monthParts = yearMonth.split('_');
    String year = (monthParts[0]);
    int monthNumber = int.parse(monthParts[1]);

    if (semester == 'July_December') {
      // Semester is from July to December
      return year == requiredYear && monthNumber >= 7 && monthNumber <= 12;
    } else if (semester == 'January_June') {
      // Semester is from January to June
      return year == requiredYear && monthNumber >= 1 && monthNumber <= 6;
    } else {
      // Unknown semester
      return false;
    }
  }

  Future<List<MessBill>> fetchMessBillsForStudent(
      String rollNumber, String semester) async {
    DateTime now = DateTime.now();
    int currentYear = now.year;
    int currentMonth = now.month;

    String currentSemester;
    String selectedSemester;
    String requiredYear;

    // Determine the current semester based on the current month
    if (currentMonth >= 1 && currentMonth <= 6) {
      currentSemester = 'January_June';
    } else {
      currentSemester = 'July_December';
    }

    if (currentSemester == 'January_June' && semester == 'Previous Semester') {
      selectedSemester = 'July_December';
      requiredYear = (currentYear - 1).toString();
    } else if (currentSemester == 'July_December' &&
        semester == 'Previous Semester') {
      selectedSemester = 'January_June';
      requiredYear = currentYear.toString();
    } else {
      selectedSemester = currentSemester;
      requiredYear = currentYear.toString();
    }
    QuerySnapshot<Map<String, dynamic>> messBillSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(rollNumber)
            .collection('monthlyBill')
            .get();

    _messBills.clear();

    messBillSnapshot.docs.forEach((messBill) {
      String yearMonth = messBill.id;

      if (isMonthInSemester(yearMonth, selectedSemester, requiredYear)) {
        print('I am here');
        _messBills.add(MessBill(
          rollNumber: rollNumber,
          totalDiets: messBill['totalDiets'],
          totalExtra: messBill['totalExtra'],
          fine: messBill['totalFine'],
          totalAmount: messBill['totalAmount'],
          extraList: (messBill['extraList'] as List<dynamic>)
              .map((item) => item as Map<String, dynamic>)
              .toList(),
          month: messBill.id,
        ));
        print('I am here also');
      }
    });

    return _messBills;
  }

  Future<void> generateBill(double perDietCost) async {
    final int previousMonth =
        DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
    final String previousMonthString = DateTime.now().month == 1
        ? '12'
        : (DateTime.now().month - 1).toString();
    final int previousMonthYear = DateTime.now().month == 1
        ? DateTime.now().year - 1
        : DateTime.now().year;
    final yearMonth =
        '${previousMonthYear}_${previousMonth.toString().padLeft(2, '0')}';

    Map<int, int> monthDays = {
      1: 31,
      2: 28,
      3: 31,
      4: 30,
      5: 31,
      6: 30,
      7: 31,
      8: 31,
      9: 30,
      10: 31,
      11: 30,
      12: 31
    };

    num _totalMonthDiets = monthDays[previousMonth]! * 3;

    QuerySnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .get();

    await Future.forEach(studentSnapshot.docs, (student) async {
      double totalExtra = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .get()
          .then((value) => value.data()!['totalExtra'] as double);

      num totalLeaves = 0;

      QuerySnapshot<Map<String, dynamic>> studentLeaveSnapshot =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(student.id)
              .collection('leaveDetails')
              .get();

      if (studentLeaveSnapshot.docs.isNotEmpty) {
        print('Hello');
        totalLeaves += studentLeaveSnapshot.docs.last['leaveCount'];
      }
      final num totalDiets = _totalMonthDiets - totalLeaves * 3;

      double totalFine = 0.0;

      QuerySnapshot<Map<String, dynamic>> studentFineSnapshot =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(student.id)
              .collection('fineDetails')
              .get();

      if (studentFineSnapshot.docs.isNotEmpty) {
        print('Hello');
        totalFine += studentFineSnapshot.docs.last['amount'];
      }

      final double totalAmount =
          totalDiets * perDietCost + totalExtra + totalFine;

      QuerySnapshot<Map<String, dynamic>> extraListSnapshot =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(student.id)
              .collection('bill')
              .where('month', isEqualTo: previousMonthString)
              .where('year', isEqualTo: previousMonthYear.toString())
              .get();

      final List<Map<String, dynamic>> extraList = [];

      if (extraListSnapshot.docs.isNotEmpty) {
        extraListSnapshot.docs.forEach((element) {
          extraList.add(element.data());
        });
      }

      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .collection('monthlyBill')
          .doc(yearMonth)
          .set({
        'totalExtra': totalExtra,
        'totalFine': totalFine,
        'totalDiets': totalDiets,
        'totalAmount': totalAmount,
        'extraList': extraList
      });
      _messBills.add(MessBill(
        rollNumber: student.id,
        totalDiets: totalDiets,
        totalExtra: totalExtra,
        fine: totalFine,
        totalAmount: totalAmount,
        extraList: extraList,
      ));
    });

    final pdfBytes = await generateMessBillPDF();
    final output = await getTemporaryDirectory();
    final file =
        File('${output.path}/mess_bill_${DateTime.now().month.toString()}.pdf');
    file.writeAsBytesSync(pdfBytes);

    AnnouncementServices().uploadAnnouncement(
        Announcement(
            title: 'Mess Bill', description: 'Mess bill for month last month'),
        file);
    OpenFilex.open(file.path);

    _messBills.clear;

    notifyListeners();
  }

  Future<Uint8List> generateMessBillPDF() async {
    Map<int, String> months = {
      1: 'January',
      2: 'February',
      3: 'March',
      4: 'April',
      5: 'May',
      6: 'June',
      7: 'July',
      8: 'August',
      9: 'September',
      10: 'October',
      11: 'November',
      12: 'December',
    };
    final int previousMonthNumber =
        DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
    final String previousMonth = months[previousMonthNumber]!;

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          // mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('Mess Bill of Month: $previousMonth',
                style: const pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 16),
            pw.TableHelper.fromTextArray(
              context: context,
              data: [
                [
                  'Roll Number',
                  'Total Diets',
                  'Total Extra',
                  'Fine',
                  'Total Amount'
                ],
                for (var messBill in _messBills)
                  [
                    messBill.rollNumber,
                    messBill.totalDiets,
                    messBill.totalExtra,
                    messBill.fine,
                    messBill.totalAmount,
                  ],
              ],
            ),
          ],
        ),
      ),
    );
    return pdf.save();
  }
}
