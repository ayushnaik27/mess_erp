import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyUser {
  String name;
  String username;
  String password;
  String role;
  MyUser(
      {required this.name,
      required this.username,
      required this.password,
      required this.role});
}

class UserProvider with ChangeNotifier {
  final MyUser _user = MyUser(name: '', username: '', password: '', role: '');

  MyUser get user {
    return _user;
  }

  Future<MyUser> getUser() async {
    return _user;
  }

  Future<MyUser> fetchUserDetails(String username,
      {bool admin = false, required String role}) async {
    if (admin) {
      final DocumentSnapshot<Map<String, dynamic>> userDetails =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection(role)
              .doc(username)
              .get();
      _user.name = userDetails['name'];
      _user.username = userDetails['email'];
      _user.password = userDetails['password'];
      _user.role = userDetails['role'];
      notifyListeners();
      print(_user.name);
      return _user;
    } else {
      final DocumentSnapshot<Map<String, dynamic>> userDetails =
          await FirebaseFirestore.instance
              .collection('loginCredentials')
              .doc('roles')
              .collection('student')
              .doc(username)
              .get();
      _user.name = userDetails['name'];
      _user.username = userDetails['rollNumber'];
      _user.password = userDetails['password'];
      _user.role = userDetails['role'];
      notifyListeners();
      return _user;
    }
  }
}
