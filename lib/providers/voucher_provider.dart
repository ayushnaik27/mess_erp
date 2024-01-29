import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:pdf/widgets.dart' as pw;

class PaymentVoucher {
  final String voucherNumber;
  final String month;
  final String year;
  final String vendorName;
  final DateTime fromDate;
  final DateTime toDate;
  final num amount;

  PaymentVoucher({
    required this.voucherNumber,
    required this.month,
    required this.year,
    required this.vendorName,
    required this.fromDate,
    required this.toDate,
    required this.amount,
  });

  // You can add methods or other customization based on your needs.
}

class PaymentVoucherProvider with ChangeNotifier {
  List<Map<String, dynamic>> _paymentVouchers = [];

  List<Map<String, dynamic>> get paymentVouchers => _paymentVouchers;

  Future<List<Map<String, dynamic>>> fetchVouchers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance.collection('paymentVouchers').get();
      _paymentVouchers = snapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
          .toList()
          .reversed
          .toList();
      notifyListeners();
      return _paymentVouchers;
    } catch (e) {
      print('Error fetching vouchers: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchPreviousVouchers(
      String selectedMonth, String selectedVendor) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('paymentVouchers')
              .where('month', isEqualTo: selectedMonth)
              .where('vendorName', isEqualTo: selectedVendor)
              .get();
      _paymentVouchers = snapshot.docs
          .map((DocumentSnapshot<Map<String, dynamic>> doc) => doc.data()!)
          .toList()
          .reversed
          .toList();
      notifyListeners();
      return _paymentVouchers;
    } catch (e) {
      print('Error fetching vouchers: $e');
      rethrow;
    }
  }

  Future<void> viewVoucher(String url, String voucherNumber) async {
    final response = await http.get(
      Uri.parse(url),
    );
    final bytes = response.bodyBytes;

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath = '${tempDir.path}/$voucherNumber.pdf';

    await File(tempDocumentPath).writeAsBytes(bytes);
    OpenFilex.open(tempDocumentPath);
  }

  Future<void> generateVoucher(
      String selectedDateRange, List<Map<String, dynamic>> voucherBills) async {
    print(voucherBills[0]);
    DateTime fromDate;
    DateTime toDate;

    // Determine the start and end dates based on the selected option.
    if (selectedDateRange == "0") {
      fromDate = DateTime(DateTime.now().year, DateTime.now().month, 1);
      toDate = DateTime(DateTime.now().year, DateTime.now().month, 15);
    } else {
      fromDate = DateTime(DateTime.now().year, DateTime.now().month, 16);
      toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
    }

    num totalAmount = 0;
    voucherBills.forEach((element) {
      totalAmount += element['billAmount'];
    });

    final voucherNumber = 'V${DateTime.now().hashCode}';

    print('Voucher Number: $voucherNumber');

    PaymentVoucher voucher = PaymentVoucher(
      voucherNumber: voucherNumber,
      month: fromDate.month.toString(),
      year: fromDate.year.toString(),
      vendorName: voucherBills[0]['vendorName'],
      fromDate: fromDate,
      toDate: toDate,
      amount: totalAmount,
    );

    generateVoucherPDF(voucher, voucherBills);
  }

  Future<void> generateVoucherPDF(
      PaymentVoucher voucher, List<Map<String, dynamic>> bills) async {
    // Generate the PDF here
    final pdf = pw.Document();

    pdf.addPage(pw.Page(
      build: (context) {
        return pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('NITJ Mess Voucher',
                style: const pw.TextStyle(fontSize: 20)),
            pw.SizedBox(height: 10),
            _buildVoucherInfo('Voucher Number', voucher.voucherNumber),
            _buildVoucherInfo('Month', voucher.month),
            _buildVoucherInfo('Vendor Name', voucher.vendorName),
            _buildVoucherInfo('From Date',
                DateFormat('dd-MM-yyyy').format(voucher.fromDate).toString()),
            _buildVoucherInfo('To Date',
                DateFormat('dd-MM-yyyy').format(voucher.toDate).toString()),
            _buildVoucherInfo('Total Amount', voucher.amount.toString()),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              data: [
                [
                  'S.No.',
                  'Bill Number',
                  'Bill Date',
                  'Bill Amount',
                ],
                for (var bill in bills)
                  [
                    bills.indexOf(bill) + 1,
                    bill['billNumber'],
                    DateFormat('dd-MM-yyyy')
                        .format(bill['billDate'].toDate())
                        .toString(),
                    bill['billAmount'],
                  ],
              ],
              context: context,
            ),
            pw.Expanded(child: pw.Container()),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('Signature of Manager',
                    style: const pw.TextStyle(fontSize: 10)),
                pw.Text('Signature of Committee',
                    style: const pw.TextStyle(fontSize: 10)),
              ],
            ),
            pw.SizedBox(height: 20),
          ],
        );
      },
    ));

    // Save the PDF
    final output = await getTemporaryDirectory();
    final file = File(join(output.path, 'example.pdf'));
    file.writeAsBytesSync(await pdf.save());
    // OpenFilex.open(file.path,type: "application/pdf");

    // Upload the PDF to Firebase Storage
    final ref = FirebaseStorage.instance
        .ref()
        .child('paymentVouchers')
        .child('${voucher.voucherNumber}.pdf');
    await ref.putFile(file);
    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance
        .collection('paymentVouchers')
        .doc(voucher.voucherNumber)
        .set({
      'voucherNumber': voucher.voucherNumber,
      'month': voucher.month,
      'vendorName': voucher.vendorName,
      'fromDate': voucher.fromDate,
      'toDate': voucher.toDate,
      'amount': voucher.amount,
      'pdfUrl': downloadUrl
    });
  }

  static pw.Widget _buildVoucherInfo(String label, String value) {
    return pw.Container(
      margin: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        children: [
          pw.Text('$label: ',
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
          pw.Text(value),
        ],
      ),
    );
  }
}
