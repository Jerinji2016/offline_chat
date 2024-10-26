import 'package:flutter/material.dart';

import '../utils/helper.dart';

class Message {
  Message(
    this.code,
    this.message,
    this.time,
    this.by,
    this.ip,
  );

  factory Message.decodeString(String string) {
    final val = decode(string);
    final buffer = StringBuffer(val[4]);

    if (val.length > 5) {
      for (var i = 5; i < val.length; i++) {
        buffer.write('$delimiter${val[i]}');
      }
    }
    debugPrint('Message: $buffer');

    final code = int.parse(val[0]);
    final by = val[1];
    final ip = val[2];
    final time = DateTime.parse(val[2]);

    return Message(code, buffer.toString(), time, by, ip);
  }

  String message;
  DateTime time;
  int code;
  String by;
  String ip;

  String encodeString() => encode([
        code.toString(),
        by,
        ip,
        time.toString(),
        message,
      ]);
}

class User {
  User(this.code, this.name, this.ip);

  int code;
  String name;
  String ip;
}
