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
  TextEditingController quantityController = TextEditingController();
  int quantity = 0;
  String rollNumber = '';
  String roomNumber = '';

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
                    roomNumber = snapshot.data!.roomNumber;
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(snapshot.data!.username,
                            style: Theme.of(context).textTheme.bodyMedium));
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
                  return Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      dropdownColor: Theme.of(context).colorScheme.primary,
                      
                      elevation: 0,
                      value: selectedItem.name,
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text(
                            'Select an extra item',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        ...Provider.of<ExtraItemsProvider>(context,
                                listen: false)
                            .extraItems
                            .map((ExtraItem item) {
                          return DropdownMenuItem(
                            value: item.name,
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  Text(
                                    'Price:  ₹${item.price}',
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ]),
                          );
                        }).toList(),
                      ],
                      onChanged: (String? value) {
                        setState(() {
                          selectedItem.name = value ?? '';
                        });
                      },
                      hint: const Text('Select an extra item'),
                      isExpanded: true,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TextFormField(
                  keyboardType: TextInputType.number,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    labelText: 'Enter Quantity',
                    focusColor: Theme.of(context).colorScheme.tertiary,
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                    prefixIconColor: Colors.black,
                    iconColor: Colors.black,
                    hoverColor: Colors.black,
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onChanged: (value) {
                    quantityController.text = value;
                  },
                ),
              ),
              const SizedBox(height: 16.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      quantity = int.tryParse(quantityController.text) ?? 0;
                    });
                    if (selectedItem.name.isEmpty || quantity == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'Please select an item and enter quantity')));
                      return;
                    }
                    ExtraItem ourItem =
                        Provider.of<ExtraItemsProvider>(context, listen: false)
                            .extraItems
                            .firstWhere(
                                (element) => element.name == selectedItem.name);
                    Provider.of<ExtraItemsProvider>(context, listen: false)
                        .addExtraItemRequest(
                            rollNumber: rollNumber,
                            roomNumber: roomNumber,
                            itemName: selectedItem.name,
                            quantity: quantity,
                            amount: ourItem.price * quantity);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Extra item request submitted'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.tertiary,
                  ),
                  child: Text(
                    'Submit Request',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
