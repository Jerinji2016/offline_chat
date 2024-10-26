import 'dart:io';

import '../utils/helper.dart';

class Person {
  Person(this.code, this.name, this.address)
      : ip = InternetAddress(
          address,
          type: InternetAddressType.IPv4,
        );

  factory Person.decodeString(String text) {
    final val = decode(text);
    final code = int.parse(val[0]);
    final name = val[1];
    final address = val[2];

    return Person(code, name, address);
  }

  final int code;
  final String address;
  final InternetAddress ip;
  final String name;

  String encodeString() => encode([
        code.toString(),
        name,
        address,
      ]);
}
