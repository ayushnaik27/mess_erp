import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:mess_erp/core/constants/firestore_constants.dart';
import 'package:mess_erp/core/utils/logger.dart';

class MonthlyReportController extends GetxController {
  final AppLogger _logger = AppLogger();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable state variables
  final RxDouble totalMonthlyExpenditure = (-1.0).obs;
  final RxDouble previousMonthStockBalance = (-1.0).obs;
  final RxDouble nextMonthStockBalance = (-1.0).obs;
  final RxDouble assetsConsumedThisMonth = (-1.0).obs;
  final RxDouble totalExtraConsumed = (-1.0).obs;
  final RxInt totalDiets = (-1).obs;
  final RxDouble couponPrice = (-1.0).obs;
  final RxDouble balance = (-1.0).obs;
  final RxDouble perDietCost = (-1.0).obs;
  final RxDouble roundedPerDietCost = (-1.0).obs;
  final RxDouble profit = (-1.0).obs;
  final RxBool isGenerating = false.obs;
  final RxBool isLoading = true.obs;

  // Cache mechanism
  final Map<String, dynamic> _cache = {};
  DateTime _cacheTimestamp = DateTime.now();
  final int _cacheDurationMinutes = 30;

  final Map<String, Map<String, dynamic>> _studentCache = {};

  @override
  void onInit() {
    super.onInit();
    _logger.i('MonthlyReportController initialized');
    loadAllData();
  }

  bool _isCacheValid(String key) {
    return _cache.containsKey(key) &&
        DateTime.now().difference(_cacheTimestamp).inMinutes <
            _cacheDurationMinutes;
  }

  void _setCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamp = DateTime.now();
  }

  Future<void> loadAllData() async {
    isLoading.value = true;

    try {
      if (_isCacheValid('allData')) {
        _loadFromCache();
        isLoading.value = false;
        return;
      }

      await Future.wait([
        getTotalExpenditure(),
        getPreviousMonthStockBalance(),
        getNextMonthStockBalance(),
        getTotalDiets(),
      ]);

      await getAssetsConsumedThisMonth();
      await getTotalExtra();

      _cacheAllData();
    } catch (e) {
      _logger.e('Error loading monthly report data', error: e);
      Get.snackbar(
        'Error',
        'Failed to load monthly report data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _loadFromCache() {
    _logger.i('Loading data from cache');

    final cachedData = _cache['allData'] as Map<String, dynamic>;
    totalMonthlyExpenditure.value = cachedData['totalMonthlyExpenditure'];
    previousMonthStockBalance.value = cachedData['previousMonthStockBalance'];
    nextMonthStockBalance.value = cachedData['nextMonthStockBalance'];
    assetsConsumedThisMonth.value = cachedData['assetsConsumedThisMonth'];
    totalExtraConsumed.value = cachedData['totalExtraConsumed'];
    totalDiets.value = cachedData['totalDiets'];

    if (cachedData.containsKey('balance')) {
      balance.value = cachedData['balance'];
    }
    if (cachedData.containsKey('perDietCost')) {
      perDietCost.value = cachedData['perDietCost'];
    }
    if (cachedData.containsKey('profit')) profit.value = cachedData['profit'];
  }

  void _cacheAllData() {
    _logger.i('Caching all data');

    _setCache('allData', {
      'totalMonthlyExpenditure': totalMonthlyExpenditure.value,
      'previousMonthStockBalance': previousMonthStockBalance.value,
      'nextMonthStockBalance': nextMonthStockBalance.value,
      'assetsConsumedThisMonth': assetsConsumedThisMonth.value,
      'totalExtraConsumed': totalExtraConsumed.value,
      'totalDiets': totalDiets.value,
      'balance': balance.value,
      'perDietCost': perDietCost.value,
      'profit': profit.value,
    });
  }

  Future<void> getTotalExpenditure() async {
    _logger.i('Calculating total expenditure');

    final String cacheKey = 'totalExpenditure';
    if (_isCacheValid(cacheKey)) {
      totalMonthlyExpenditure.value = _cache[cacheKey];
      _logger.i(
          'Using cached total expenditure: ${totalMonthlyExpenditure.value}');
      return;
    }

    DateTime now = DateTime.now();
    DateTime firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
    DateTime lastDayOfPreviousMonth =
        firstDayOfCurrentMonth.subtract(const Duration(days: 1));
    DateTime firstDayOfPreviousMonth =
        DateTime(lastDayOfPreviousMonth.year, lastDayOfPreviousMonth.month, 1);

    double total = 0;

    try {
      QuerySnapshot<Map<String, dynamic>> voucherSnapshot = await _firestore
          .collection(FirestoreConstants.vouchers)
          .where('year', isEqualTo: firstDayOfPreviousMonth.year.toString())
          .where('month', isEqualTo: firstDayOfPreviousMonth.month.toString())
          .get();

      for (var voucher in voucherSnapshot.docs) {
        total += double.parse(voucher['amount'].toString());
      }

      totalMonthlyExpenditure.value = total;
      _setCache(cacheKey, total);
      _logger.i('Total monthly expenditure: $total');
    } catch (e) {
      _logger.e('Error calculating total expenditure', error: e);
      throw e;
    }
  }

  Future<void> getPreviousMonthStockBalance() async {
    _logger.i('Getting previous month stock balance');
    try {
      int currentMonth = DateTime.now().month;
      int currentYear = DateTime.now().year;

      int previousMonth = currentMonth == 1 ? 12 : currentMonth - 1;
      int previousYear = currentMonth == 1 ? currentYear - 1 : currentYear;

      QuerySnapshot<Map<String, dynamic>> balanceSnapshot = await _firestore
          .collection(FirestoreConstants.stock)
          .orderBy('transactionDate', descending: true)
          .get();

      QueryDocumentSnapshot<Map<String, dynamic>>? requiredSnapshot;

      for (var doc in balanceSnapshot.docs) {
        if (doc['date']['month'] == previousMonth &&
            doc['date']['year'] == previousYear) {
          requiredSnapshot = doc;
          break;
        }
      }

      if (requiredSnapshot != null) {
        previousMonthStockBalance.value =
            double.parse(requiredSnapshot['balance'].toString());
        _logger.i(
            'Previous month stock balance: ${previousMonthStockBalance.value}');
      } else {
        _logger.w('No stock record found for previous month');
      }
    } catch (e) {
      _logger.e('Error getting previous month stock balance', error: e);
      throw e;
    }
  }

  Future<void> getNextMonthStockBalance() async {
    _logger.i('Getting next month stock balance');
    try {
      QuerySnapshot<Map<String, dynamic>> balanceSnapshot =
          await _firestore.collection(FirestoreConstants.stock).get();

      if (balanceSnapshot.docs.isNotEmpty) {
        QueryDocumentSnapshot<Map<String, dynamic>> requiredSnapshot =
            balanceSnapshot.docs.last;
        nextMonthStockBalance.value =
            double.parse(requiredSnapshot['balance'].toString());
        _logger.i('Next month stock balance: ${nextMonthStockBalance.value}');
      } else {
        _logger.w('No stock records found');
      }
    } catch (e) {
      _logger.e('Error getting next month stock balance', error: e);
      throw e;
    }
  }

  Future<void> getAssetsConsumedThisMonth() async {
    _logger.i('Calculating assets consumed this month');
    try {
      if (totalMonthlyExpenditure.value == -1) await getTotalExpenditure();
      if (previousMonthStockBalance.value == -1) {
        await getPreviousMonthStockBalance();
      }
      if (nextMonthStockBalance.value == -1) await getNextMonthStockBalance();

      assetsConsumedThisMonth.value = totalMonthlyExpenditure.value +
          previousMonthStockBalance.value -
          nextMonthStockBalance.value;

      _logger.i('Assets consumed this month: ${assetsConsumedThisMonth.value}');
    } catch (e) {
      _logger.e('Error calculating assets consumed', error: e);
      throw e;
    }
  }

  Future<void> getTotalExtra() async {
    _logger.i('Calculating total extra consumed');

    final String cacheKey = 'totalExtra';
    if (_isCacheValid(cacheKey)) {
      totalExtraConsumed.value = _cache[cacheKey];
      _logger.i('Using cached total extra: ${totalExtraConsumed.value}');
      return;
    }

    try {
      double totalExtra = 0.0;

      if (_studentCache.isEmpty) {
        QuerySnapshot<Map<String, dynamic>> studentSnapshot = await _firestore
            .collection(FirestoreConstants.loginCredentials)
            .doc(FirestoreConstants.roles)
            .collection(FirestoreConstants.students)
            .get();

        for (var student in studentSnapshot.docs) {
          _studentCache[student.id] = student.data();
        }
      }

      WriteBatch batch = _firestore.batch();
      int batchCount = 0;

      final studentIds = _studentCache.keys.toList();
      for (int i = 0; i < studentIds.length; i += 10) {
        final chunk = studentIds.sublist(
            i, i + 10 > studentIds.length ? studentIds.length : i + 10);

        await Future.forEach(chunk, (String studentId) async {
          QuerySnapshot<Map<String, dynamic>> studentExtraSnapshot =
              await _firestore
                  .collection(FirestoreConstants.loginCredentials)
                  .doc(FirestoreConstants.roles)
                  .collection(FirestoreConstants.students)
                  .doc(studentId)
                  .collection(FirestoreConstants.bills)
                  .get();

          double studentExtra = 0.0;

          for (var extraBill in studentExtraSnapshot.docs) {
            if (extraBill.data().containsKey('items')) {
              List<dynamic> extraItems = extraBill['items'];
              for (var element in extraItems) {
                studentExtra += (element['amount'] ?? 0).toDouble();
              }
            }
          }

          _logger.i('Student $studentId extra: $studentExtra');

          batch.set(
              _firestore
                  .collection(FirestoreConstants.loginCredentials)
                  .doc(FirestoreConstants.roles)
                  .collection(FirestoreConstants.students)
                  .doc(studentId),
              {'totalExtra': studentExtra},
              SetOptions(merge: true));

          batchCount++;

          if (batchCount >= 20) {
            await batch.commit();
            batch = _firestore.batch();
            batchCount = 0;
          }

          totalExtra += studentExtra;
        });
      }

      if (batchCount > 0) {
        await batch.commit();
      }

      totalExtraConsumed.value = totalExtra;
      _setCache(cacheKey, totalExtra);
      _logger.i('Total extra consumed: $totalExtra');
    } catch (e) {
      _logger.e('Error calculating total extra', error: e);
      throw e;
    }
  }

  Future<void> getTotalDiets() async {
    _logger.i('Calculating total diets');
    try {
      int previousMonth =
          DateTime.now().month == 1 ? 12 : DateTime.now().month - 1;

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

      final int year = DateTime.now().year;
      if (previousMonth == 2 &&
          (year % 4 == 0 && (year % 100 != 0 || year % 400 == 0))) {
        monthAndDays[2] = 29;
      }

      num TD = monthAndDays[previousMonth]! * 3;
      num totalLeaves = 0;

      QuerySnapshot<Map<String, dynamic>> studentSnapshot = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.students)
          .get();

      await Future.forEach(studentSnapshot.docs, (student) async {
        QuerySnapshot<Map<String, dynamic>> studentLeaveSnapshot =
            await _firestore
                .collection(FirestoreConstants.loginCredentials)
                .doc(FirestoreConstants.roles)
                .collection(FirestoreConstants.students)
                .doc(student.id)
                .collection('newLeaveDetails')
                .get();

        if (studentLeaveSnapshot.docs.isNotEmpty) {
          for (var leave in studentLeaveSnapshot.docs) {
            totalLeaves += leave['onLeaveMeals'].length;
          }
        }
      });

      TD -= totalLeaves;
      totalDiets.value = TD.toInt();
      _logger.i('Total diets: ${totalDiets.value}');
    } catch (e) {
      _logger.e('Error calculating total diets', error: e);
      throw e;
    }
  }

  void setCouponPrice(double price) {
    couponPrice.value = price;
    calculateBalance();
  }

  Future<void> calculateBalance() async {
    _logger.i('Calculating balance');
    try {
      if (assetsConsumedThisMonth.value == -1)
        await getAssetsConsumedThisMonth();
      if (totalExtraConsumed.value == -1) await getTotalExtra();

      double cp = couponPrice.value == -1 ? 0.0 : couponPrice.value;

      balance.value =
          -totalExtraConsumed.value + assetsConsumedThisMonth.value - cp;
      _logger.i('Balance: ${balance.value}');

      calculatePerDietCost();
    } catch (e) {
      _logger.e('Error calculating balance', error: e);
      throw e;
    }
  }

  Future<void> calculatePerDietCost() async {
    _logger.i('Calculating per diet cost');
    try {
      if (balance.value == -1) await calculateBalance();
      if (totalDiets.value == -1) await getTotalDiets();

      perDietCost.value = balance.value / totalDiets.value;
      _logger.i('Per diet cost: ${perDietCost.value}');
    } catch (e) {
      _logger.e('Error calculating per diet cost', error: e);
      throw e;
    }
  }

  void setRoundedPerDietCost(double cost) {
    roundedPerDietCost.value = cost;
    calculateProfit();
  }

  Future<void> calculateProfit() async {
    _logger.i('Calculating profit');
    try {
      if (perDietCost.value == -1) await calculatePerDietCost();
      if (totalDiets.value == -1) await getTotalDiets();

      double rpdCost =
          roundedPerDietCost.value == -1 ? 0.0 : roundedPerDietCost.value;
      profit.value = (rpdCost - perDietCost.value) * totalDiets.value;
      _logger.i('Profit: ${profit.value}');
    } catch (e) {
      _logger.e('Error calculating profit', error: e);
      throw e;
    }
  }

  Future<void> generateBill() async {
    _logger.i('Generating bills');
    isGenerating.value = true;

    try {
      await deleteLeaves();
      await deleteOldBills();
      await generateStudentBills();

      invalidateCache();

      Get.snackbar(
        'Success',
        'Bills generated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Get.theme.colorScheme.onPrimary,
      );
    } catch (e) {
      _logger.e('Error generating bills', error: e);
      Get.snackbar(
        'Error',
        'Failed to generate bills: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Get.theme.colorScheme.onError,
      );
    } finally {
      isGenerating.value = false;
    }
  }

  Future<void> generateStudentBills() async {
    _logger.i('Generating student bills');
    try {
      if (roundedPerDietCost.value == -1) {
        throw Exception('Rounded per diet cost not set');
      }

      // Implement the actual bill generation logic here
      // This would need to be adapted from your MessBillProvider
    } catch (e) {
      _logger.e('Error generating student bills', error: e);
      throw e;
    }
  }

  Future<void> deleteOldBills() async {
    _logger.i('Deleting old bills');
    try {
      // If we already have student cache, use it
      List<String> studentIds;
      if (_studentCache.isNotEmpty) {
        studentIds = _studentCache.keys.toList();
      } else {
        QuerySnapshot<Map<String, dynamic>> studentSnapshot = await _firestore
            .collection(FirestoreConstants.loginCredentials)
            .doc(FirestoreConstants.roles)
            .collection(FirestoreConstants.students)
            .get();

        studentIds = studentSnapshot.docs.map((doc) => doc.id).toList();

        // Cache students for future use
        for (var student in studentSnapshot.docs) {
          _studentCache[student.id] = student.data();
        }
      }

      int deletedBills = 0;
      // Process in smaller chunks to avoid memory issues
      for (int i = 0; i < studentIds.length; i += 5) {
        final chunk = studentIds.sublist(
            i, i + 5 > studentIds.length ? studentIds.length : i + 5);

        WriteBatch batch = _firestore.batch();
        int batchSize = 0;

        await Future.forEach(chunk, (String studentId) async {
          QuerySnapshot<Map<String, dynamic>> billSnapshot = await _firestore
              .collection(FirestoreConstants.loginCredentials)
              .doc(FirestoreConstants.roles)
              .collection(FirestoreConstants.students)
              .doc(studentId)
              .collection(FirestoreConstants.bills)
              .limit(20) // Process in pages to avoid large queries
              .get();

          for (var bill in billSnapshot.docs) {
            batch.delete(bill.reference);
            batchSize++;
            deletedBills++;

            // Firebase has a limit of 500 operations per batch
            if (batchSize >= 400) {
              await batch.commit();
              batch = _firestore.batch();
              batchSize = 0;
            }
          }
        });

        // Commit any remaining operations
        if (batchSize > 0) {
          await batch.commit();
        }
      }

      _logger.i('Old bills deleted: $deletedBills');
    } catch (e) {
      _logger.e('Error deleting old bills', error: e);
      throw e;
    }
  }

  Future<void> deleteLeaves() async {
    _logger.i('Deleting leaves');
    try {
      QuerySnapshot<Map<String, dynamic>> studentSnapshot = await _firestore
          .collection(FirestoreConstants.loginCredentials)
          .doc(FirestoreConstants.roles)
          .collection(FirestoreConstants.students)
          .get();

      await Future.forEach(studentSnapshot.docs, (student) async {
        // Delete leave details
        QuerySnapshot<Map<String, dynamic>> leaveSnapshot = await _firestore
            .collection(FirestoreConstants.loginCredentials)
            .doc(FirestoreConstants.roles)
            .collection(FirestoreConstants.students)
            .doc(student.id)
            .collection('newLeaveDetails')
            .get();

        for (var leave in leaveSnapshot.docs) {
          await leave.reference.delete();
        }

        // Reset total extra
        await _firestore
            .collection(FirestoreConstants.loginCredentials)
            .doc(FirestoreConstants.roles)
            .collection(FirestoreConstants.students)
            .doc(student.id)
            .set({
          'totalExtra': 0.0,
        }, SetOptions(merge: true));

        // Delete fine details
        QuerySnapshot<Map<String, dynamic>> fineSnapshot = await _firestore
            .collection(FirestoreConstants.loginCredentials)
            .doc(FirestoreConstants.roles)
            .collection(FirestoreConstants.students)
            .doc(student.id)
            .collection('fineDetails')
            .get();

        for (var fine in fineSnapshot.docs) {
          await fine.reference.delete();
        }
      });

      _logger.i('Leaves and fines deleted');
    } catch (e) {
      _logger.e('Error deleting leaves and fines', error: e);
      throw e;
    }
  }

  // Add this method to clear the cache when needed
  void invalidateCache() {
    _logger.i('Invalidating cache');
    _cache.clear();
    _studentCache.clear();
    _cacheTimestamp = DateTime.now();
  }
}
