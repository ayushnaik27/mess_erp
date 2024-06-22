import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MonthlyReportProvider with ChangeNotifier {
  double _totalMonthlyExpenditure = -1.0;
  double get totalMonthlyExpenditure => _totalMonthlyExpenditure;

  double _previousMonthStockBalance = -1.0;
  double get previousMonthStockBalance => _previousMonthStockBalance;

  double _nextMonthStockBalance = -1.0;
  double get nextMonthStockBalance => _nextMonthStockBalance;

  double _assetsConsumedThisMonth = -1.0;
  double get assetsConsumedThisMonth => _assetsConsumedThisMonth;

  double _totalExtraConsumed = -1.0;
  double get totalExtraConsumed => _totalExtraConsumed;

  int _totalDiets = -1;
  int get totalDiets => _totalDiets;

  double _couponPrice = -1.0;
  double get couponPrice => _couponPrice;

  double _balance = -1.0;
  double get balance => _balance;

  double _perDietCost = -1.0;
  double get perDietCost => _perDietCost;

  double _roundedPerDietCost = -1.0;
  double get roundedPerDietCost => _roundedPerDietCost;

  double _profit = -1.0;
  double get profit => _profit;

  Future<double> getTotalExpenditure() async {
    print('calculateTotalExpenditure');
    DateTime now = DateTime.now();
    DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfPreviousMonth =
        firstDayOfCurrentMonth.subtract(const Duration(days: 1));
    DateTime firstDayOfPreviousMonth =
        DateTime(lastDayOfPreviousMonth.year, lastDayOfPreviousMonth.month, 1);

    double totalMonthlyExpenditure = 0;

    print(firstDayOfPreviousMonth.year.toString());

    QuerySnapshot<Map<String, dynamic>> voucherSnapshot =
        await FirebaseFirestore.instance
            .collection('paymentVouchers')
            .where('year', isEqualTo: firstDayOfPreviousMonth.year.toString())
            .where('month', isEqualTo: firstDayOfPreviousMonth.month.toString())
            .get();
    voucherSnapshot.docs.forEach((voucher) {
      totalMonthlyExpenditure += double.parse(voucher['amount'].toString());
    });

    _totalMonthlyExpenditure = totalMonthlyExpenditure;
    notifyListeners();
    return totalMonthlyExpenditure;
  }

  Future<double> getPreviousMonthStockBalance() async {
    print('getpreviousMonthStockBalance');
    DateTime now = DateTime.now();

    int currentMonth = now.month;
    int currentYear = now.year;

    int previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
    int previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;

    QuerySnapshot<Map<String, dynamic>> balanceSnapshot =
        await FirebaseFirestore.instance.collection('stock').get();

    QueryDocumentSnapshot<Map<String, dynamic>> requiredSnapshot =
        balanceSnapshot.docs.firstWhere((element) =>
            element['date']['month'] == previousMonth &&
            element['date']['year'] == previousYear);

    _previousMonthStockBalance = double.parse(requiredSnapshot['balance'].toString());
    notifyListeners();
    return double.parse(requiredSnapshot['balance'].toString());
  }

  Future<double> getNextMonthStockBalance() async {
    QuerySnapshot<Map<String, dynamic>> balanceSnapshot =
        await FirebaseFirestore.instance.collection('stock').get();

    QueryDocumentSnapshot<Map<String, dynamic>> requiredSnapshot =
        balanceSnapshot.docs.last;
    _nextMonthStockBalance = requiredSnapshot['balance'];
    notifyListeners();
    return requiredSnapshot['balance'];
  }

  Future<double> getAssetsConsumedThisMonth() async {
    double TME = _totalMonthlyExpenditure == -1
        ? await getTotalExpenditure()
        : _totalMonthlyExpenditure;
    double LMSB = _previousMonthStockBalance == -1
        ? await getPreviousMonthStockBalance()
        : _previousMonthStockBalance;

    double NMSB = _nextMonthStockBalance == -1
        ? await getNextMonthStockBalance()
        : _nextMonthStockBalance;

    _assetsConsumedThisMonth = TME + LMSB - NMSB;
    notifyListeners();
    return _assetsConsumedThisMonth;
  }

  Future<double> getTotalExtra() async {
    log('getTotalExtra');
    print('getTotalExtra');
    double totalExtra = 0.0;

    QuerySnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .get();

    await Future.forEach(studentSnapshot.docs, (student) async {
      QuerySnapshot<Map<String, dynamic>> studentExtraSnapshot =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(student.id)
              .collection('bill')
              .get();

      double studentExtra = 0.0;

      await Future.forEach(studentExtraSnapshot.docs, (extraBill) {
        List<dynamic> extraItems = extraBill['items'];
        extraItems.forEach((element) {
          studentExtra += element['amount'];
        });
      });

      log('Student Extra $studentExtra');

      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .set({
        'totalExtra': studentExtra,
      }, SetOptions(merge: true));
      totalExtra += studentExtra;
    });

    _totalExtraConsumed = totalExtra;
    notifyListeners();
    return totalExtra;
  }

  Future<int> getTotalDiets() async {
    print('getTotalDiets');
    int previousMonth =
        DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;
    int currentMonth = DateTime.now().month;
    Map<int, int> monthAndDays = {
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
      12: 31,
    };

    num TD = monthAndDays[previousMonth]! * 3;
    num totalLeaves = 0;
    QuerySnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .get();

    await Future.forEach(studentSnapshot.docs, (student) async {
      QuerySnapshot<Map<String, dynamic>> studentLeaveSnapshot =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(student.id)
              .collection('newLeaveDetails')
              .get();

      if (studentLeaveSnapshot.docs.isNotEmpty) {
        print('Hello');
        studentLeaveSnapshot.docs.forEach((leave) {
          totalLeaves += leave['onLeaveMeals'].length;
        });
      }
    });

    TD -= totalLeaves;
    _totalDiets = TD.toInt();
    notifyListeners();
    log('Total Diets: $_totalDiets');
    return _totalDiets;
  }

  void setCouponPrice(double price) {
    _couponPrice = price;
  }

  Future<double> getBalance() async {
    double ACTM = _assetsConsumedThisMonth == -1
        ? await getAssetsConsumedThisMonth()
        : _assetsConsumedThisMonth;
    double TEC =
        _totalExtraConsumed == -1 ? await getTotalExtra() : _totalExtraConsumed;

    double CP = _couponPrice == -1 ? 0.0 : _couponPrice;

    _balance = -TEC + ACTM - CP;
    notifyListeners();
    return _balance;
  }

  Future<double> getPerDietCost() async {
    double balance = _balance == -1 ? await getBalance() : _balance;
    int totalDiets = _totalDiets == -1 ? await getTotalDiets() : _totalDiets;

    _perDietCost = balance / totalDiets;
    notifyListeners();
    return _perDietCost;
  }

  void setRoundedPerDietCost(double cost) {
    _roundedPerDietCost = cost;
  }

  Future<double> getProfit() async {
    double perDietCost =
        _perDietCost == -1 ? await getPerDietCost() : _perDietCost;
    double roundedPerDietCost =
        _roundedPerDietCost == -1 ? 0.0 : _roundedPerDietCost;
    int totalDiets = _totalDiets == -1 ? await getTotalDiets() : _totalDiets;
    double profit = (roundedPerDietCost - perDietCost) * totalDiets;

    _profit = profit;
    notifyListeners();
    return profit;
  }

  Future<void> generateBill() async {}

  Future<void> deleteOldBills() async {
    QuerySnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .get();

    await Future.forEach(studentSnapshot.docs, (student) async {
      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .collection('bill')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
    });
  }

  Future<void> deleteLeaves() async {
    QuerySnapshot<Map<String, dynamic>> studentSnapshot =
        await FirebaseFirestore.instance
            .collection('loginCredentials')
            .doc('roles')
            .collection('student')
            .get();

    await Future.forEach(studentSnapshot.docs, (student) async {
      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .collection('newLeaveDetails')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });

      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .set({
        'totalExtra': 0.0,
      }, SetOptions(merge: true));
    });

    // Delete fine details

    await Future.forEach(studentSnapshot.docs, (student) async {
      await FirebaseFirestore.instance
          .collection('loginCredentials')
          .doc('roles')
          .collection('student')
          .doc(student.id)
          .collection('fineDetails')
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
      });
    });
  }
}
