import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/extra_item_provider.dart';

class ExtraItemsScreen extends StatefulWidget {
  static const routeName = '/extraItems';
  @override
  _ExtraItemsScreenState createState() => _ExtraItemsScreenState();
}

class _ExtraItemsScreenState extends State<ExtraItemsScreen> {
  TextEditingController itemNameController = TextEditingController();
  TextEditingController itemPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ExtraItemsProvider extraItemsProvider =
        Provider.of<ExtraItemsProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Extra Items Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Manage Extra Items:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: FutureBuilder(
                  future: extraItemsProvider.fetchExtraItems(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return Consumer<ExtraItemsProvider>(
                        builder: (context, extraItemData, child) =>
                            ListView.builder(
                          itemCount: extraItemData.extraItems.length,
                          itemBuilder: (context, index) {
                            final item = extraItemData.extraItems[index];
                            return ListTile(
                              title: Text(
                                '${item.name} - ₹${item.price.toString()}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      _showEditItemDialog(item);
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('Delete ${item.name}'),
                                              content: Text(
                                                  'Are you sure you want to delete ${item.name} ?'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text('Cancel'),
                                                ),
                                                ElevatedButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                    extraItemData
                                                        .deleteExtraItem(
                                                            item.id!);
                                                    setState(() {});
                                                  },
                                                  child: const Text('Delete'),
                                                ),
                                              ],
                                            );
                                          });
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    }
                  }),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                _showAddItemDialog();
              },

              style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                ),
                child: Text(
                  'Add New Item',
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.tertiary),
                ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Extra Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                decoration: const InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: itemPriceController,
                decoration: const InputDecoration(labelText: 'Item Price'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Provider.of<ExtraItemsProvider>(context, listen: false)
                    .addExtraItem(
                        itemNameController.text.trim(),
                        double.tryParse(itemPriceController.text.trim()) ??
                            0.0);
                Navigator.of(context).pop();
                setState(() {
                  itemNameController.clear();
                  itemPriceController.clear();
                });
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _showEditItemDialog(ExtraItem item) {
    itemNameController.text = item.name;
    itemPriceController.text = item.price.toString();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Extra Item',
              style: Theme.of(context).textTheme.bodyMedium),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: itemNameController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Item Name',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
              TextField(
                controller: itemPriceController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  labelText: 'Item Price',
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // _editItem(item);
                Provider.of<ExtraItemsProvider>(context, listen: false)
                    .editExtraItem(
                        item.id!,
                        itemNameController.text.trim(),
                        double.tryParse(itemPriceController.text.trim()) ??
                            0.0);
                Navigator.of(context).pop();
                setState(() {
                  itemNameController.clear();
                  itemPriceController.clear();
                });
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }
}
