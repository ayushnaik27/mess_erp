import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../clerk/mess_bill_provider.dart';
import 'mess_bill_details_screen.dart';

class MessBillScreen extends StatefulWidget {
  static const routeName = '/messBill';
  final String studentId;

  const MessBillScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _MessBillScreenState createState() => _MessBillScreenState();
}

class _MessBillScreenState extends State<MessBillScreen> {
  String selectedSemester = 'Current Semester';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Bill'),
      ),
      body: Column(
        children: [
          _buildSemesterDropdown(),
          Expanded(child: _buildMessBillList(context)),
        ],
      ),
    );
  }

  Widget _buildSemesterDropdown() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DropdownButton<String>(
        value: selectedSemester,
        onChanged: (String? newValue) {
          if (newValue != null && newValue != selectedSemester) {
            setState(() {
              selectedSemester = newValue;
            });
          }
        },
        items: <String>['Current Semester', 'Previous Semester']
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessBillList(BuildContext context) {
    return FutureBuilder<List<MessBill>>(
      future: Provider.of<MessBillProvider>(context, listen: false)
          .fetchMessBillsForStudent(widget.studentId, selectedSemester),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No mess bills available.'));
        } else {
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return _buildMessBillItem(context, snapshot.data![index]);
            },
          );
        }
      },
    );
  }

  Widget _buildMessBillItem(BuildContext context, MessBill messBill) {
    final monthNumber = messBill.month!.split('_')[1];
    return ListTile(
      title: Text('Month: $monthNumber',
          style: Theme.of(context).textTheme.titleMedium),
      subtitle: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Total Diets: ${messBill.totalDiets}  ',
                style: Theme.of(context).textTheme.bodySmall),
            Text('Total Extra: ${messBill.totalExtra}  ',
                style: Theme.of(context).textTheme.bodySmall),
            Text('Fine: ${messBill.fine}  ',
                style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
      trailing: IconButton(
        onPressed: () {
          log('View mess bill details');
          log('${messBill.extraList}');
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => MessBillDetailsScreen(messBill: messBill),
          ));
        },
        icon: const Icon(Icons.arrow_forward_ios),
      ),
    );
  }
}
