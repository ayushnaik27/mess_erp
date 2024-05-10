import 'package:flutter/material.dart';
import 'package:mess_erp/providers/user_provider.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';

class RequestExtraItemsScreen extends StatefulWidget {
  static const routeName = '/requestExtraItems';

  const RequestExtraItemsScreen({super.key});

  @override
  _RequestExtraItemsScreenState createState() =>
      _RequestExtraItemsScreenState();
}

class _RequestExtraItemsScreenState extends State<RequestExtraItemsScreen> {
  // String selectedItem = '';
  ExtraItem selectedItem = ExtraItem(name: '', price: 0);

  int quantity = 0;
  String rollNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Extra Items'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FutureBuilder(
                  future: Provider.of<UserProvider>(context, listen: false)
                      .getUser(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Container();
                    }
                    rollNumber = snapshot.data!.username;
                    return Text(snapshot.data!.username);
                  }),
              FutureBuilder(
                future: Provider.of<ExtraItemsProvider>(context, listen: false)
                    .fetchExtraItems(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  return DropdownButton<String>(
                    value: selectedItem.name,
                    items: [
                      const DropdownMenuItem(
                          value: '', child: Text('Select an extra item')),
                      ...Provider.of<ExtraItemsProvider>(context, listen: false)
                          .extraItems
                          .map((ExtraItem item) {
                        return DropdownMenuItem(
                          value: item.name,
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start
                            ,children: [
                            Text(item.name),
                            Text('Price:  ₹${item.price}',style: TextStyle(fontSize: 10),),
                          ]),
                        );
                      }).toList(),

                      // Add extra item names fetched from table 5
                    ],
                    onChanged: (String? value) {
                      setState(() {
                        selectedItem.name = value ?? '';
                      });
                    },
                    hint: const Text('Select an extra item'),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Enter Quantity'),
                onChanged: (value) {
                  setState(() {
                    quantity = int.tryParse(value) ?? 0;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  print('Selected Item: $selectedItem, Quantity: $quantity');
                  if (selectedItem.name.isEmpty || quantity == 0) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('Please select an item and enter quantity')));
                    return;
                  }
                  ExtraItem ourItem =
                      Provider.of<ExtraItemsProvider>(context, listen: false)
                          .extraItems
                          .firstWhere(
                              (element) => element.name == selectedItem.name);
                  print(ourItem.name);
                  print(ourItem.price);

                  Provider.of<ExtraItemsProvider>(context, listen: false)
                      .addExtraItemRequest(
                          rollNumber: rollNumber,
                          itemName: selectedItem.name,
                          quantity: quantity,
                          amount: ourItem.price * quantity);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Extra item request submitted')));
                  Navigator.of(context).pop();
                },
                child: const Text('Submit Request'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
