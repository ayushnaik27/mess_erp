import 'package:flutter/material.dart';

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
  late double ratePerUnit;
  late int quantityReceived;
  late bool isOtherItem;
  TextEditingController otherItemController = TextEditingController();

  @override
  void initState() {
    super.initState();
    itemName = 'Atta'; // Default to 'Atta'
    isOtherItem = false;
  }

  @override
  Widget build(BuildContext context) {
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
              DropdownButton<String>(
                value: itemName,
                onChanged: (value) {
                  setState(() {
                    itemName = value!;
                    isOtherItem = itemName == 'Other';
                  });
                },
                items: [
                  'Rice',
                  'Atta',
                  'Oil',
                  'Butter',
                  'Milk',
                  'Curd',
                  'Pulses',
                  'Grams',
                  'Cereals'
                  'Tea',
                  'Cornflakes',
                  'Maggie',
                  'Other',
                ].map((name) =>
                        DropdownMenuItem(value: name, child: Text(name)))
                    .toList(),
              ),
              if (isOtherItem)
                TextField(
                  controller: otherItemController,
                  onChanged: (value) {
                    itemName = value;
                  },
                  decoration:
                      const InputDecoration(labelText: 'Enter Item Name'),
                ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  ratePerUnit = double.tryParse(value) ?? 0.0;
                },
                decoration: const InputDecoration(labelText: 'Rate per Unit'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              TextField(
                onChanged: (value) {
                  quantityReceived = int.tryParse(value) ?? 0;
                },
                decoration:
                    const InputDecoration(labelText: 'Quantity Received'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (isOtherItem && itemName.isEmpty) {
                    // Handle the case where Other is selected, but the item name is not entered
                    return;
                  }
                  widget.onAddItem(
                    ItemEntry(
                      itemName: itemName,
                      ratePerUnit: ratePerUnit,
                      quantityReceived: quantityReceived,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Add Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
