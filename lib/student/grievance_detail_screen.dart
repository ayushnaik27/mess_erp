import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:mess_erp/api_keys.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'package:pdf/widgets.dart' as pdf;
import 'package:provider/provider.dart';

import '../providers/grievance_provider.dart';

class GrievanceDetailScreen extends StatefulWidget {
  static const routeName = '/grievanceDetail';

  final Grievance grievance;
  final bool isStudent;

  GrievanceDetailScreen(
      {Key? key, required this.grievance, required this.isStudent})
      : super(key: key);

  @override
  _GrievanceDetailScreenState createState() => _GrievanceDetailScreenState();
}

class _GrievanceDetailScreenState extends State<GrievanceDetailScreen> {
  late bool showReminderButton;
  late String receipentEmail;

  @override
  void initState() {
    super.initState();
    showReminderButton = _shouldShowRemainderButton();
  }

  // bool _shouldShowRemainderButton() {
  //   DateTime now = DateTime.now();
  //   DateTime lastUpdated = widget.grievance.history.last['date'].toDate();
  //   String lastAction = widget.grievance.history.last['action'];

  //   if (lastAction == 'Reminder Sent' &&
  //       now.difference(lastUpdated).inDays + 1 < 7) {
  //     return false;
  //   }

  //   if (lastAction == 'Reminder Sent' &&
  //       now.difference(lastUpdated).inDays + 1 >= 7) {
  //     setState(() {
  //       receipentEmail = 'deepak.it.22@nitj.ac.in';
  //     });
  //     return true;
  //   }

  //   if (now.difference(lastUpdated).inDays + 1 >= 7) {
  //     setState(() {
  //       receipentEmail = 'naveenk.it.22@nitj.ac.in';
  //     });
  //   }

  //   if (now.difference(lastUpdated).inDays + 1 >= 14 &&
  //       widget.grievance.reminderCount == 1) {
  //     setState(() {
  //       receipentEmail = 'deepakm.it.22@nitj.ac.in';
  //     });
  //   }

  //   return now.difference(lastUpdated).inDays + 1 >= 7 &&
  //       widget.grievance.status == 'pending';
  // }

  bool _shouldShowRemainderButton() {
    DateTime now = DateTime.now();
    DateTime lastUpdated = widget.grievance.history.last['date'].toDate();
    String lastAction = widget.grievance.history.last['action'];

    bool isFirstReminderSent = widget.grievance.reminderCount > 0;

    if (lastAction == 'Reminder Sent' &&
        now.difference(lastUpdated).inDays + 1 < 7) {
      return false;
    }

    if (!isFirstReminderSent) {
      setState(() {
        receipentEmail = 'naveenk.it.22@nitj.ac.in';
      });
      return true;
    }

    if (lastAction == 'Reminder Sent' &&
        now.difference(lastUpdated).inDays + 1 >= 7) {
      setState(() {
        receipentEmail = 'deepak.it.22@nitj.ac.in';
      });
      return true;
    }

    if (now.difference(lastUpdated).inDays + 1 >= 7) {
      setState(() {
        receipentEmail = 'naveenk.it.22@nitj.ac.in';
      });
    }

    if (now.difference(lastUpdated).inDays + 1 >= 14 && !isFirstReminderSent) {
      setState(() {
        receipentEmail = 'deepakm.it.22@nitj.ac.in';
      });
    }

    return now.difference(lastUpdated).inDays + 1 >= 7 &&
            widget.grievance.status == 'pending' ||
        widget.grievance.status == 'in progress';
  }

  Future<File> generateHistoryPDF() async {
    final pdf.Document doc = pdf.Document();
    doc.addPage(
      pdf.Page(build: (context) {
        return pdf.Column(
          children: [
            pdf.Text('Grievance History',
                style: pdf.TextStyle(fontWeight: pdf.FontWeight.bold)),
            pdf.SizedBox(height: 20),
            pdf.Row(children: [
              pdf.Text('Grievance ID: '),
              pdf.Text(widget.grievance.grievanceId),
            ]),
            pdf.SizedBox(height: 10),
            pdf.Row(children: [
              pdf.Text('Filed on: '),
              pdf.Text(DateFormat.yMMMMd()
                  .format(widget.grievance.dateOfFiling)
                  .toString()),
            ]),
            pdf.SizedBox(height: 10),
            pdf.Row(children: [
              pdf.Text('Filed by: '),
              pdf.Text(
                  '${widget.grievance.name} (${widget.grievance.studentRollNo})'),
            ]),
            pdf.SizedBox(height: 20),
            pdf.Table.fromTextArray(
              context: context,
              data: <List<String>>[
                <String>['Updated By', 'Date', 'Action', 'Remarks'],
                ...widget.grievance.history.reversed.map((entry) {
                  return <String>[
                    entry['updatedBy'],
                    DateFormat.yMMMMd()
                        .format(entry['date'].toDate())
                        .toString(),
                    entry['action'],
                    entry['remarks'],
                  ];
                }).toList(),
              ],
            ),
          ],
        );
      }),
    );

    final tempDir = await getTemporaryDirectory();
    final tempDocumentPath =
        '${tempDir.path}/${widget.grievance.grievanceId}.pdf';
    doc.save().then((value) => File(tempDocumentPath).writeAsBytes(value!));
    return File(tempDocumentPath);
  }

  void _sendReminderEmail(String receipentEmail, int x) async {
    // Implement remainder functionality
    // Use the grievance object to get the required details
    // Use the sendRemainder method of the GrievanceProvider
    print('Sending email to $receipentEmail');

    try {
      String username = 'naikayush68@gmail.com';
      String password = passWord;

      final smtpServer = gmail(username, password);
      String studentName = widget.grievance
          .name; // Get the name of the student from the grievance object

      File file = await generateHistoryPDF();

      final message1 = Message()
        ..from = Address(username)
        ..recipients.add(receipentEmail)
        ..subject =
            'Reminder! No action on complaint ${widget.grievance.grievanceId} for last $x days'
        ..text =
            'Dear MBH F \n\nThis is a gentle reminder sent by $studentName that no action has been taken by you on his complaint ${widget.grievance.grievanceId} for last $x days.\nPlease look into it on urgent basis.\n\nRegardsMess \nERP Notifications Team';

      // final message2 = Message()
      //   ..from = Address(username)
      //   ..recipients.add('ayush27naik27@gmail.com')
      //   ..attachments.add(FileAttachment(file))
      //   ..subject =
      //       'MBH F not taking any action on complaint ${widget.grievance.grievanceId} of $studentName for last $x days'
      //   ..text =
      //       'Dear Sir,\n\nThis is a gentle reminder sent by $studentName that their complaint no. ${widget.grievance.grievanceId} is pending with Hostel MBH F, and no action has been taken by the said hostel for the last $x days. \n\nPlease look into it on an urgent basis. \n\nDetails regarding the complaint is attached with the mail.\n\nRegards,\nMess ERP Notifications Team';

      final message2 = Message()
        ..from = Address(username)
        ..recipients.add(receipentEmail)
        ..attachments.add(FileAttachment(file))
        ..subject =
            'MBH F not taking any action on complaint ${widget.grievance.grievanceId} of $studentName for last $x days'
        ..html = '''
      <p>Dear Sir,</p>
      <p>This is a gentle reminder sent by $studentName that his complaint no. ${widget.grievance.grievanceId} is pending with Hostel MBH F, and no action has been taken by the said hostel for the last $x days.</p>
      <p>Please look into it on an urgent basis.</p>
      <p>More details regarding the complaint are attached herewith.</p>
      <p>Regards,<br>Mess ERP Notifications Team</p>
  ''';

      if (receipentEmail == 'naveenk.it.22@gmail.com') {
        final sendReport = await send(message1, smtpServer);
        print('Message sent: $sendReport');
      } else {
        final sendReport = await send(message2, smtpServer);
        print('Message sent: $sendReport');
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reminder email sent successfully'),
        ),
      );

      setState(() {
        showReminderButton = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.grievance.grievanceTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filed on:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                      ' ${DateFormat.yMMMMd().format(widget.grievance.dateOfFiling)}')
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Filed by:',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(widget.grievance.studentRollNo),
                ],
              ),
              const SizedBox(height: 8.0),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Status: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.grievance.status,
                  ),
                ],
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Description:',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(widget.grievance.grievanceDesc),
              const SizedBox(height: 32.0),
              if (widget.grievance.fileUpload.isNotEmpty)
                ElevatedButton(
                  onPressed: () async {
                    // Implement file download functionality
                    final response = await http.get(
                      Uri.parse(widget.grievance.fileUpload),
                    );
                    final bytes = response.bodyBytes;

                    final tempDir = await getTemporaryDirectory();
                    final tempDocumentPath =
                        '${tempDir.path}/${widget.grievance.grievanceId}.pdf';

                    await File(tempDocumentPath).writeAsBytes(bytes);
                    OpenFilex.open(tempDocumentPath);
                    // Use the fileUpload field of the grievance object
                  },
                  child: const Text('View Supporting Document'),
                ),
              const SizedBox(height: 16.0),
              HistoryTable(history: widget.grievance.history.reversed.toList()),
            ],
          ),
        ),
      ),
      floatingActionButton: widget.isStudent
          ? (showReminderButton
              ? widget.grievance.reminderCount >= 2
                  ? const ElevatedButton(
                      onPressed: null,
                      child: Text('Reminder Sent'),
                    )
                  : ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Send Reminder'),
                            content: const Text(
                                'Do you want to send a reminder email to the assigned person?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) {
                                    return Scaffold(
                                      appBar: AppBar(
                                        title: const Text('Sending Reminder'),
                                      ),
                                      body: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    );
                                  }));
                                  DateTime lastUpdated = widget
                                      .grievance.history.last['date']
                                      .toDate();
                                  String lastAction =
                                      widget.grievance.history.last['action'];
                                  if (lastAction == 'Reminder Sent') {
                                    lastUpdated = widget
                                        .grievance
                                        .history[
                                            widget.grievance.history.length - 2]
                                            ['date']
                                        .toDate();
                                  }
                                  int x = DateTime.now()
                                          .difference(lastUpdated)
                                          .inDays +
                                      1;
                                  _sendReminderEmail(receipentEmail, x);

                                  String studentName = widget.grievance
                                      .name; // Get the name of the student from the grievance object
                                  final newEntry = {
                                    'date': Timestamp.now(),
                                    'updatedBy': studentName,
                                    'action': 'Reminder Sent',
                                    'remarks':
                                        'Reminder sent to $receipentEmail'
                                  };

                                  setState(() {
                                    widget.grievance.history.add(newEntry);
                                    showReminderButton = false;
                                  });

                                  await FirebaseFirestore.instance
                                      .collection('grievances')
                                      .doc(widget.grievance.grievanceId)
                                      .update({
                                    'reminderCount': FieldValue.increment(1),
                                    'history': FieldValue.arrayUnion([
                                      {
                                        'date': Timestamp.now(),
                                        'updatedBy': studentName,
                                        'action': 'Reminder Sent',
                                        'remarks':
                                            'Reminder sent to $receipentEmail'
                                      }
                                    ])
                                  });
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.email),
                      label: const Text('Send Reminder'),
                    )
              : null)
          : null,
    );
  }
}

class HistoryTable extends StatelessWidget {
  final List<Map<String, dynamic>> history;

  const HistoryTable({required this.history});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        dataRowMinHeight: 10,
        dataRowMaxHeight: 100,
        columns: const [
          DataColumn(label: Text('Updated By')),
          DataColumn(label: Text('Date')),
          DataColumn(label: Text('Action')),
          DataColumn(label: Text('Remarks')),
        ],
        rows: history.map((entry) {
          return DataRow(cells: [
            DataCell(
              Text(capitalize(entry['updatedBy']) ?? ''),
            ),
            DataCell(SizedBox(
                width: 100, child: Text(_formatDate(entry['date'].toDate())))),
            DataCell(Text(entry['action'] ?? '')),
            DataCell(
              SizedBox(
                width: 300,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Remarks'),
                        content: SingleChildScrollView(
                          child: Text(entry['remarks'] ?? ''),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(entry['remarks'] ?? '',
                      overflow: TextOverflow.ellipsis, maxLines: 3),
                ),
              ),
            ),
          ]);
        }).toList(),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? 'On ${DateFormat.yMMMMd().format(date)} at ${DateFormat.jm().format(date)}'
        : '';
  }

  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
}
