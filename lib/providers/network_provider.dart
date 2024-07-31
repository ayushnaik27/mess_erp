import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class NetworkProvider with ChangeNotifier{
  Connectivity _connectivity = Connectivity();

  bool isInternetOn = false;

  Stream<void> connect() {
    return _connectivity.onConnectivityChanged.map((event) {
      if (event == ConnectivityResult.none) {
        isInternetOn = false;
      } else {
        isInternetOn = true;
      }
      notifyListeners();
    });


  }



  

  

  

  
  

}