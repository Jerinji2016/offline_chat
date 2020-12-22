import 'dart:io';

import 'package:offline_chat/utils/helper.dart';

class Person {
  final int code;
  final String address;
  InternetAddress ip;
  final String name;

  Person(this.code, this.name, this.address) : super() {
    this.ip = InternetAddress(
      address,
      type: InternetAddressType.IPv4,
    );
  }

  String encodeString() => encode([
        code.toString(),
        name,
        address,
      ]);

  static Person decodeString(String text) {
    List<String> val = decode(text);
    int code = int.parse(val[0]);
    String name = val[1];
    String address = val[2];

    return new Person(code, name, address);
  }
}
