import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  final String rollNumber;

  const QRScannerScreen({super.key, required this.rollNumber});
  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late BuildContext _context;
  late NavigatorState _navigator;
  MobileScannerController controller = MobileScannerController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _navigator = Navigator.of(context);
  }

  void _navigateToScreen(Widget screen) {
    _navigator.push(MaterialPageRoute(builder: (context) => screen));
  }

  void _showDialog(Widget dialog) {
    showDialog(context: context, builder: (context) => dialog);
  }

  Future<bool> checkLeave(DateTime date, String rollNumber) async {
    String leaveDate = DateFormat('dd-MM-yyyy').format(date);
    try {
      DocumentSnapshot leaveSnapshot = await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(rollNumber)
          .collection('newLeaveDetails')
          .doc(leaveDate)
          .get();

      if (leaveSnapshot.exists) {
        DateTime currentTime = DateTime.now();
        Map<String, dynamic> leaveData = leaveSnapshot.data() as Map<String, dynamic>;

        if (currentTime.hour < 10 && leaveData['onLeaveMeals'].contains('Breakfast')) {
          return true;
        } else if (currentTime.hour < 15 && leaveData['onLeaveMeals'].contains('Lunch')) {
          return true;
        } else if (leaveData['onLeaveMeals'].contains('Dinner')) {
          return true;
        }
      }
    } catch (e) {
      log('Error checking leave: $e');
    }
    return false;
  }

  Future<void> handleQRCodeDetected(String? value) async {
    if (value == 'ABCD') {
      log('QR Code matched');
      controller.stop();

      try {
        DocumentSnapshot livePlatesSnapshot = await FirebaseFirestore.instance
            .collection('livePlates')
            .doc(widget.rollNumber)
            .get();

        if (livePlatesSnapshot.exists) {
          _navigateToScreen(const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cancel, color: Colors.red, size: 100),
                  Text('Already scanned for this meal'),
                ],
              ),
            ),
          ));
          return;
        }

        bool isOnLeave = await checkLeave(DateTime.now(), widget.rollNumber);

        if (isOnLeave) {
          await handleOnLeaveCase();
        } else {
          await markMealAsScanned();
          _navigateToScreen(const Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 100),
                  Text('Successfully scanned'),
                ],
              ),
            ),
          ));
        }
      } catch (e) {
        log('Error handling QR code detection: $e');
      }
    }
  }

  Future<void> handleOnLeaveCase() async {
    int mealsOnLeave = await calculateMealsOnLeave();
    String fromDate = '';
    String toDate = '';
    DocumentSnapshot leaveSnapshot = await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .doc(widget.rollNumber)
        .collection('newLeaveDetails')
        .doc(DateFormat('dd-MM-yyyy').format(DateTime.now()))
        .get();

    if (leaveSnapshot.exists) {
      Map<String, dynamic> leaveData = leaveSnapshot.data() as Map<String, dynamic>;
      fromDate = leaveData['fromDate'];
      toDate = leaveData['toDate'];
    }

    if (mealsOnLeave > 3) {
      _showDialog(AlertDialog(
        title: const Text('You are on leave'),
        content: Text('You are on leave from $fromDate to $toDate. Do you want to revoke it? '
            'Leave will be revoked for all meals from this meal onwards.'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')),
          TextButton(
              onPressed: () async {
                await revokeLeave(fromDate: fromDate, toDate: toDate);
                await markMealAsScanned();
                _navigateToScreen(const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 100),
                        Text('Successfully scanned'),
                      ],
                    ),
                  ),
                ));
              },
              child: const Text('Yes')),
        ],
      ));
    } else {
      _showDialog(AlertDialog(
        title: const Text('You are on leave'),
        content: const Text('You are on leave for less than 3 meals. Do you want to revoke it? '
            'Entire leave will be revoked.'),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No')),
          TextButton(
              onPressed: () async {
                await revokeLeave(fromDate: fromDate, toDate: toDate);
                await markMealAsScanned();
                _navigateToScreen(const Scaffold(
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 100),
                        Text('Successfully scanned'),
                      ],
                    ),
                  ),
                ));
              },
              child: const Text('Yes')),
        ],
      ));
    }
  }

  Future<int> calculateMealsOnLeave() async {
    int mealsOnLeave = 0;

    DocumentSnapshot leaveSnapshot = await FirebaseFirestore.instance
        .collection('loginCredentials')
        .doc('roles')
        .collection('student')
        .doc(widget.rollNumber)
        .collection('newLeaveDetails')
        .doc(DateFormat('dd-MM-yyyy').format(DateTime.now()))
        .get();

    if (leaveSnapshot.exists) {
      String fromDate = leaveSnapshot['fromDate'];
      String toDate = leaveSnapshot['toDate'];

      DateTime fromDateTime = DateTime(
          int.parse(fromDate.split('-')[2]),
          int.parse(fromDate.split('-')[1]),
          int.parse(fromDate.split('-')[0]));

      DateTime toDateTime = DateTime(
          int.parse(toDate.split('-')[2]),
          int.parse(toDate.split('-')[1]),
          int.parse(toDate.split('-')[0]));

      for (DateTime date = fromDateTime; date.isBefore(DateTime.now()); date = date.add(const Duration(days: 1))) {
        DocumentSnapshot currentLeaveSnapshot = await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .doc(widget.rollNumber)
            .collection('newLeaveDetails')
            .doc(DateFormat('dd-MM-yyyy').format(date))
            .get();

        if (currentLeaveSnapshot.exists) {
          Map<String, dynamic> currentLeaveData = currentLeaveSnapshot.data() as Map<String, dynamic>;
          DateTime currentTime = DateTime.now();

          if (currentTime.hour < 10 && currentLeaveData['onLeaveMeals'].contains('Breakfast')) {
            mealsOnLeave++;
          } else if (currentTime.hour < 15 && currentLeaveData['onLeaveMeals'].contains('Lunch')) {
            mealsOnLeave++;
          } else if (currentLeaveData['onLeaveMeals'].contains('Dinner')) {
            mealsOnLeave++;
          }
        }
      }
    }

    return mealsOnLeave;
  }

  Future<void> revokeLeave({required String fromDate, required String toDate}) async {
    DateTime fromDateTime = DateTime(
        int.parse(fromDate.split('-')[2]),
        int.parse(fromDate.split('-')[1]),
        int.parse(fromDate.split('-')[0]));

    DateTime toDateTime = DateTime(
        int.parse(toDate.split('-')[2]),
        int.parse(toDate.split('-')[1]),
        int.parse(toDate.split('-')[0]));

    for (DateTime date = fromDateTime; date.isBefore(toDateTime.add(const Duration(days: 1))); date = date.add(const Duration(days: 1))) {
      DocumentReference leaveDocRef = FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(widget.rollNumber)
          .collection('newLeaveDetails')
          .doc(DateFormat('dd-MM-yyyy').format(date));

      if (DateFormat('dd-MM-yyyy').format(date) == DateFormat('dd-MM-yyyy').format(DateTime.now())) {
        DocumentSnapshot leaveDocSnapshot = await leaveDocRef.get();

        if (leaveDocSnapshot.exists) {
          Map<String, dynamic> leaveDocData = leaveDocSnapshot.data() as Map<String, dynamic>;
          DateTime currentTime = DateTime.now();

          if (currentTime.hour < 10) {
            leaveDocData['onLeaveMeals'].remove('Breakfast');
          } else if (currentTime.hour < 15) {
            leaveDocData['onLeaveMeals'].remove('Lunch');
          } else {
            leaveDocData['onLeaveMeals'].remove('Dinner');
          }

          await leaveDocRef.set(leaveDocData, SetOptions(merge: true));
        }
      } else {
        await leaveDocRef.delete();
      }
    }
  }

  Future<void> markMealAsScanned() async {
    await FirebaseFirestore.instance
        .collection('livePlates')
        .doc(widget.rollNumber)
        .set({
      'rollNumber': widget.rollNumber,
      'time': DateTime.now(),
    });
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 400,
              width: 400,
              child: MobileScanner(
                controller: controller,
                onDetect: (BarcodeCapture data) async {
                  String? qrCodeValue = data.barcodes.first.displayValue;
                  log('QR Code detected: $qrCodeValue');
                  await handleQRCodeDetected(qrCodeValue);
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
