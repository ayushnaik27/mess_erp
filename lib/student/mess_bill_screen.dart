import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../clerk/mess_bill_provider.dart';

class MessBillScreen extends StatefulWidget {
  static const routeName = '/messBill';
  final String studentId;

  const MessBillScreen({Key? key, required this.studentId}) : super(key: key);

  @override
  _MessBillScreenState createState() => _MessBillScreenState();
}

class _MessBillScreenState extends State<MessBillScreen> {
  String selectedSemester = 'Current Semester';
  // Add necessary logic to fetch mess bills and other functionalities

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mess Bill'),
      ),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedSemester,
            onChanged: (String? newValue) {
              setState(() {
                selectedSemester = newValue!;
                // Fetch mess bills for the selected semester here
                // You can call a function to get the mess bills based on the selected semester
              });
            },
            items: <String>['Current Semester', 'Previous Semester']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          Container(
            height: 500,
            child: FutureBuilder<List<MessBill>>(
              // Add your logic to fetch mess bills here
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
                  // Display mess bills
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final monthNumber =
                          snapshot.data![index].month!.split('_')[1];
                      return ListTile(
                        title: Text('Month: $monthNumber'),
                        subtitle: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Total Diets: ${snapshot.data![index].totalDiets}  '),
                            Text(
                                'Total Extra: ${snapshot.data![index].totalExtra}  '),
                            Text('Fine: ${snapshot.data![index].fine}  '),
                          ],
                        ),
                        trailing: IconButton(onPressed: (){}, icon: Icon(Icons.arrow_forward_ios)),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
