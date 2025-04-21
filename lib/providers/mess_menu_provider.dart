import 'package:flutter/material.dart';

class MessItem {
  final String name;
  final String price;

  MessItem({required this.name, required this.price});
}

class MessMenuProvider with ChangeNotifier {
  List<MessItem> _messMenu = [
    MessItem(name: 'Rice', price: '20'),
    MessItem(name: 'Dal', price: '20'),
    MessItem(name: 'Sabji', price: '20'),
    MessItem(name: 'Roti', price: '20'),
    MessItem(name: 'Salad', price: '20'),
    MessItem(name: 'Rice', price: '20'),
    MessItem(name: 'Dal', price: '20'),
    MessItem(name: 'Sabji', price: '20'),
    MessItem(name: 'Roti', price: '20'),
    MessItem(name: 'Salad', price: '20'),
    MessItem(name: 'Rice', price: '20'),
    MessItem(name: 'Dal', price: '20'),
    MessItem(name: 'Sabji', price: '20'),
    MessItem(name: 'Roti', price: '20'),
    MessItem(name: 'Salad', price: '20'),
    MessItem(name: 'Rice', price: '20'),
    MessItem(name: 'Dal', price: '20'),
    MessItem(name: 'Sabji', price: '20'),
    MessItem(name: 'Roti', price: '20'),
    MessItem(name: 'Salad', price: '20'),
    MessItem(name: 'Rice', price: '20'),
    MessItem(name: 'Dal', price: '20'),
    MessItem(name: 'Sabji', price: '20'),
    MessItem(name: 'Roti', price: '20'),
    MessItem(name: 'Salad', price: '20'),
  ];

  List<MessItem> get messMenu {
    return [..._messMenu];
  }

  void addMessItem(MessItem messItem) {
    _messMenu.add(messItem);
    notifyListeners();
  }

  void removeMessItem(MessItem messItem) {
    _messMenu.remove(messItem);
    notifyListeners();
  }
}
