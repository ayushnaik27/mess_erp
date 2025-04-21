import 'package:flutter/material.dart';
import 'package:mess_erp/providers/itemListProvider.dart';
import 'package:provider/provider.dart';

// Model class for an item entry
class ItemEntry {
  final String itemName;
  final double ratePerUnit;
  final int quantityReceived;

  ItemEntry({
    required this.itemName,
    required this.ratePerUnit,
    required this.quantityReceived,
  });
}

class AddItemScreen extends StatefulWidget {
  final Function(ItemEntry) onAddItem;

  const AddItemScreen({Key? key, required this.onAddItem}) : super(key: key);

  @override
  _AddItemScreenState createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  late String itemName;
  late double ratePerUnit = 0.0;
  late int quantityReceived = 0;
  late bool isOtherItem;
  late String otherItemName;
  TextEditingController otherItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    isOtherItem = false;
    fetchItems();
  }

  void fetchItems() async {
    await Provider.of<ItemListProvider>(context, listen: false)
        .fetchAndSetItems();
    setState(() {
      itemName = Provider.of<ItemListProvider>(context, listen: false)
              .items
              .contains('Atta')
          ? 'Atta'
          : Provider.of<ItemListProvider>(context, listen: false).items.first;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> items = Provider.of<ItemListProvider>(context).items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Item'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (items.isNotEmpty)
                DropdownButton<String>(
                  value: itemName,
                  onChanged: (value) {
                    setState(() {
                      itemName = value!;
                      isOtherItem = itemName == '';
                    });
                  },
                  items: [
                    ...items.map((String item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item),
                      );
                    }).toList(),
                    const DropdownMenuItem<String>(
                      value: '',
                      child: Text('Other'),
                    ),
                  ],
                ),
              if (isOtherItem)
                TextField(
                  controller: otherItemController,
                  onChanged: (value) {
                    setState(() {
                      otherItemName = value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: 'Enter Item Name',
                    labelStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  ratePerUnit = double.tryParse(value) ?? 0.0;
                },
                decoration: InputDecoration(
                  labelText: 'Rate per Unit',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  quantityReceived = int.tryParse(value) ?? 0;
                },
                decoration: InputDecoration(
                  labelText: 'Quantity Received',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () async {
                  if (ratePerUnit <= 0 || quantityReceived <= 0) {
                    // Handle the case where rate per unit or quantity received is not entered
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text(
                                'Please enter the rate per unit and quantity received'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        });
                    return;
                  }
                  if (isOtherItem && otherItemName.isEmpty) {
                    // Handle the case where Other is selected, but the item name is not entered
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: const Text('Please enter the item name'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        });
                    return;
                  }
                  // await Provider.of<ItemListProvider>(context, listen: false)
                  //     .addItem(isOtherItem ? otherItemName : itemName, ratePerUnit);

                  isOtherItem
                      ? await Provider.of<ItemListProvider>(context,
                              listen: false)
                          .addItem(otherItemName, ratePerUnit)
                      : await Provider.of<ItemListProvider>(context,
                              listen: false)
                          .editItem(itemName, ratePerUnit);
                  widget.onAddItem(
                    ItemEntry(
                      itemName: isOtherItem ? otherItemName : itemName,
                      ratePerUnit: ratePerUnit,
                      quantityReceived: quantityReceived,
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Add Item',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
