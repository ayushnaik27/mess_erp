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
    _navigator.push(MaterialPageRoute(builder: (context) {
      return screen;
    }));
  }

  void _showDialog(Widget dialog) {
    showDialog(context: context, builder: (context) => dialog);
  }

  Future<bool> checkLeave(DateTime date, String rollNumber) async {
    String leaveDate = DateFormat('dd-MM-yyyy').format(date);

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

      if (currentTime.hour < 10) {
        if (leaveSnapshot['onLeaveMeals'].contains('Breakfast')) {
          return true;
        }
      } else if (currentTime.hour < 15) {
        if (leaveSnapshot['onLeaveMeals'].contains('Lunch')) {
          return true;
        }
      } else {
        if (leaveSnapshot['onLeaveMeals'].contains('Dinner')) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
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
                    log('QR Code detected: ${data.barcodes.first.displayValue}');

                    if (data.barcodes.first.displayValue == 'ABCD') {
                      log('QR Code matched');
                      // Implement the logic to handle the detected QR code

                      controller.stop();

                      final DocumentSnapshot livePlatesSnapshot =
                          await FirebaseFirestore.instance
                              .collection('livePlates')
                              .doc(widget.rollNumber)
                              .get();

                      if (livePlatesSnapshot.exists) {
                        log('Plate already scanned');
                        _navigateToScreen(const Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.cancel,
                                    color: Colors.red, size: 100),
                                Text('Already scanned for this meal')
                              ],
                            ),
                          ),
                        ));
                        return;
                      }

                      bool isOnLeave =
                          await checkLeave(DateTime.now(), widget.rollNumber);

                      if (isOnLeave) {
                        // Check if the student was on leave for more than 3 meals
                        int mealsOnLeave = 0;
                        bool onLeaveForMoreThan3Meals = false;

                        DocumentSnapshot leaveSnapshot = await FirebaseFirestore
                            .instance
                            .collection('loginCredentials')
                            .doc('roles')
                            .collection('student')
                            .doc(widget.rollNumber)
                            .collection('newLeaveDetails')
                            .doc(
                                DateFormat('dd-MM-yyyy').format(DateTime.now()))
                            .get();

                        log('From Date: ${leaveSnapshot.data()}');

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

                        for (DateTime date = fromDateTime;
                            date.isBefore(DateTime.now());
                            date = date.add(const Duration(days: 1))) {
                          DocumentSnapshot currentLeaveSnapshot =
                              await FirebaseFirestore.instance
                                  .collection('loginCredentials')
                                  .doc('roles')
                                  .collection('student')
                                  .doc(widget.rollNumber)
                                  .collection('newLeaveDetails')
                                  .doc(DateFormat('dd-MM-yyyy').format(date))
                                  .get();

                          DateTime currentTime = DateTime.now();

                          if (currentTime.hour < 10) {
                            DateTime previousThreeMealDate =
                                date.subtract(const Duration(days: 1));
                            DocumentSnapshot previousThreeMealLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy')
                                        .format(previousThreeMealDate))
                                    .get();

                            if (previousThreeMealLeaveSnapshot.exists) {
                              Map<String, dynamic> previousThreeMealData =
                                  previousThreeMealLeaveSnapshot.data()
                                      as Map<String, dynamic>;
                              if (previousThreeMealData['onLeaveMeals']
                                  .contains('Dinner')) {
                                mealsOnLeave++;
                                if (previousThreeMealData['onLeaveMeals']
                                    .contains('Lunch')) {
                                  mealsOnLeave++;
                                  if (previousThreeMealData['onLeaveMeals']
                                      .contains('Breakfast')) {
                                    mealsOnLeave++;
                                  }
                                }
                              }
                            }
                          } else if (currentTime.hour < 15) {
                            DateTime previousTwoMealDate =
                                date.subtract(const Duration(days: 1));
                            DocumentSnapshot previousTwoMealLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy')
                                        .format(previousTwoMealDate))
                                    .get();

                            DocumentSnapshot currentLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy').format(date))
                                    .get();

                            if (currentLeaveSnapshot.exists) {
                              Map<String, dynamic> currentLeaveData =
                                  currentLeaveSnapshot.data()
                                      as Map<String, dynamic>;

                              if (currentLeaveData['onLeaveMeals']
                                  .contains('Breakfast')) {
                                mealsOnLeave++;
                              }
                            }

                            if (previousTwoMealLeaveSnapshot.exists) {
                              Map<String, dynamic> previousTwoMealData =
                                  previousTwoMealLeaveSnapshot.data()
                                      as Map<String, dynamic>;
                              if (previousTwoMealData['onLeaveMeals']
                                  .contains('Dinner')) {
                                mealsOnLeave++;
                                if (previousTwoMealData['onLeaveMeals']
                                    .contains('Lunch')) {
                                  mealsOnLeave++;
                                }
                              }
                            }
                          } else if (currentTime.hour < 22) {
                            DateTime previousOneMealDate =
                                date.subtract(const Duration(days: 1));
                            DocumentSnapshot previousOneMealLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy')
                                        .format(previousOneMealDate))
                                    .get();

                            DocumentSnapshot currentLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy').format(date))
                                    .get();

                            if (currentLeaveSnapshot.exists) {
                              Map<String, dynamic> currentLeaveData =
                                  currentLeaveSnapshot.data()
                                      as Map<String, dynamic>;

                              if (currentLeaveData['onLeaveMeals']
                                  .contains('Lunch')) {
                                mealsOnLeave++;
                                if (currentLeaveData['onLeaveMeals']
                                    .contains('Breakfast')) {
                                  mealsOnLeave++;
                                }
                              }
                            }

                            if (previousOneMealLeaveSnapshot.exists) {
                              Map<String, dynamic> previousOneMealData =
                                  previousOneMealLeaveSnapshot.data()
                                      as Map<String, dynamic>;
                              if (previousOneMealData['onLeaveMeals']
                                  .contains('Dinner')) {
                                mealsOnLeave++;
                              }
                            }
                          } else {
                            DateTime previousThreeMealDate =
                                date.subtract(const Duration(days: 1));

                            DocumentSnapshot previousThreeMealLeaveSnapshot =
                                await FirebaseFirestore.instance
                                    .collection('loginCredentials')
                                    .doc('roles')
                                    .collection('student')
                                    .doc(widget.rollNumber)
                                    .collection('newLeaveDetails')
                                    .doc(DateFormat('dd-MM-yyyy')
                                        .format(previousThreeMealDate))
                                    .get();

                            if (previousThreeMealLeaveSnapshot.exists) {
                              Map<String, dynamic> previousThreeMealData =
                                  previousThreeMealLeaveSnapshot.data()
                                      as Map<String, dynamic>;
                              if (previousThreeMealData['onLeaveMeals']
                                  .contains('Dinner')) {
                                mealsOnLeave++;
                                if (previousThreeMealData['onLeaveMeals']
                                    .contains('Lunch')) {
                                  mealsOnLeave++;
                                  if (previousThreeMealData['onLeaveMeals']
                                      .contains('Breakfast')) {
                                    mealsOnLeave++;
                                  }
                                }
                              }
                            }
                          }
                        }

                        log('Meals on leave: $mealsOnLeave');

                        if (mealsOnLeave > 3) {
                          // Student was on leave for more than 3 meals, ask them to revoke meal
                          // Show UI to ask student to revoke meal
                          _showDialog(AlertDialog(
                            title: const Text('You are on leave'),
                            content: Text(
                                'You are on leave from $fromDate to $toDate. Do you want to revoke it? Leave will be revoked for all meals from this meal onwards.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () async {
                                    // Revoke the leave
                                    for (DateTime date = DateTime.now();
                                        date.isBefore(toDateTime
                                            .add(const Duration(days: 1)));
                                        date =
                                            date.add(const Duration(days: 1))) {
                                      DocumentReference leaveDocRef =
                                          FirebaseFirestore.instance
                                              .collection('loginCredentials')
                                              .doc('roles')
                                              .collection('student')
                                              .doc(widget.rollNumber)
                                              .collection('newLeaveDetails')
                                              .doc(DateFormat('dd-MM-yyyy')
                                                  .format(date));

                                      DocumentSnapshot leaveDocSnapshot =
                                          await leaveDocRef.get();

                                      Map<String, dynamic> leaveDocData =
                                          leaveDocSnapshot.data()
                                              as Map<String, dynamic>;

                                      String leaveDocDateString =
                                          DateFormat('dd-MM-yyyy').format(date);

                                      if (leaveDocDateString ==
                                          DateFormat('dd-MM-yyyy')
                                              .format(DateTime.now())) {
                                        log(leaveDocData.toString());
                                        DateTime currentTime = DateTime.now();

                                        if (currentTime.hour < 10) {
                                          leaveDocData['onLeaveMeals']
                                              .remove('Breakfast');
                                              
                                          
                                        } else if (currentTime.hour < 15) {
                                          leaveDocData['onLeaveMeals']
                                              .remove('Lunch');
                                        } else {
                                          leaveDocData['onLeaveMeals']
                                              .remove('Dinner');
                                        }

                                        leaveDocRef.set(leaveDocData,
                                            SetOptions(merge: true));

                                        continue;
                                      }

                                      log('n');

                                      leaveDocRef.delete();
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Leave revoked Successfully')));

                                    Navigator.of(_context).pop();

                                    await FirebaseFirestore.instance
                                        .collection('livePlates')
                                        .doc(widget.rollNumber)
                                        .set({
                                      'rollNumber': widget.rollNumber,
                                      'time': DateTime.now(),
                                    });

                                    _navigateToScreen(const Scaffold(
                                      body: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 100),
                                            Text('Successfully scanned')
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                  child: const Text('Yes')),
                            ],
                          ));
                        } else {
                          // Student was on leave for 3 or fewer meals, show green tick and success
                          // Show UI with green tick and success message
                          _showDialog(AlertDialog(
                            title: const Text('You are on leave'),
                            content: const Text(
                                'You are on leave for less than 3 meals. Do you want to revoke it? Entire leave will be revoked.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () async {
                                    // Revoke the leave
                                    for (DateTime date = fromDateTime;
                                        date.isBefore(toDateTime
                                            .add(const Duration(days: 1)));
                                        date =
                                            date.add(const Duration(days: 1))) {
                                      DocumentReference leaveDocRef =
                                          FirebaseFirestore.instance
                                              .collection('loginCredentials')
                                              .doc('roles')
                                              .collection('student')
                                              .doc(widget.rollNumber)
                                              .collection('newLeaveDetails')
                                              .doc(DateFormat('dd-MM-yyyy')
                                                  .format(date));

                                      leaveDocRef.delete();
                                    }

                                    ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Leave revoked Successfully')));

                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();

                                    await FirebaseFirestore.instance
                                        .collection('livePlates')
                                        .doc(widget.rollNumber)
                                        .set({
                                      'rollNumber': widget.rollNumber,
                                      'time': DateTime.now(),
                                    });

                                    _navigateToScreen(const Scaffold(
                                      body: Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.check_circle,
                                                color: Colors.green, size: 100),
                                            Text('Successfully scanned')
                                          ],
                                        ),
                                      ),
                                    ));
                                  },
                                  child: const Text('Yes')),
                            ],
                          ));
                        }
                      } else {
                        log('Student is not on leave');
                        await FirebaseFirestore.instance
                            .collection('livePlates')
                            .doc(widget.rollNumber)
                            .set({
                          'rollNumber': widget.rollNumber,
                          'time': DateTime.now(),
                        });
                        _navigateToScreen(const Scaffold(
                          body: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.check_circle,
                                    color: Colors.green, size: 100),
                                Text('Successfully scanned')
                              ],
                            ),
                          ),
                        ));
                        // Student is not on leave, show green tick and success
                        // Show UI with green tick and success message
                      }
                    }
                  }),
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
