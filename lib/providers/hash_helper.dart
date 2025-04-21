import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:pointycastle/export.dart';
import 'package:pointycastle/pointycastle.dart';

class HashHelper {
  static final KeyParameter key =
      KeyParameter(utf8.encode('MESSERPSYSTEMNITJ'));
  static final Mac mac = Mac('SHA-256/HMAC')..init(key);

  static String encode(String data) {
    final List<int> bytes = utf8.encode(data);
    final List<int> digest = mac.process(Uint8List.fromList(bytes));
    return base64.encode(digest);
  }

  static bool verify(String data, String hash) {
    return hash == encode(data);
  }
}
