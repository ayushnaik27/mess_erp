import 'package:flutter/material.dart';
import 'package:mess_erp/providers/stock_provider.dart';
import 'package:provider/provider.dart';

class IssueStockScreen extends StatefulWidget {
  static const routeName = '/issueStock';

  @override
  _IssueStockScreenState createState() => _IssueStockScreenState();
}

class _IssueStockScreenState extends State<IssueStockScreen> {
  late String selectedItem; // Selected item from dropdown
  int quantityToIssue = 0; // Quantity to issue
  double currentBalance = 0; // Current balance (initially set to 0)
  int itemQuantity = 0; // Quantity of the selected item

  // Dummy list of items for the dropdown (replace it with your actual items)
  Map<String, double> items = {
    'x1': 10.0,
    'y1': 20.0,
    'z1': 30.0,
  };
  // List<String> items = ['x1', 'y1', 'z1', 'Other'];

  @override
  void initState() {
    super.initState();
    getBalance();
    selectedItem = 'x1'; // Default to 'x1'
  }

  void getBalance() async {
    await Provider.of<StockProvider>(context, listen: false)
        .fetchBalance()
        .then((value) {
      setState(() {
        currentBalance = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issue Stock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<String>(
                value: selectedItem,
                onChanged: (value) {
                  setState(() {
                    selectedItem = value!;
                  });
                },
                items: [
                  ...items.keys.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                ]),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  quantityToIssue = int.tryParse(value) ?? 0;
                });
              },
              decoration:
                  const InputDecoration(labelText: 'Enter Quantity to Issue'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                // Perform the stock issuing logic here
                final double amount = items[selectedItem]! * quantityToIssue;
                await Provider.of<StockProvider>(context, listen: false)
                    .issueStock(selectedItem, quantityToIssue, amount);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Issued $quantityToIssue units of $selectedItem to mess'),
                  ),
                );
                Navigator.of(context).pop();
              },
              child: const Text('Submit'),
            ),
            const SizedBox(height: 16),
            FutureBuilder(
              future: Provider.of<StockProvider>(context, listen: false)
                  .fetchStockBalance(selectedItem),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container();
                }
                itemQuantity = snapshot.data as int;
                return Text('Item Quantity: $itemQuantity');
              },
            ),
            Text("Current Balance: $currentBalance"),
          ],
        ),
      ),
    );
  }
}
