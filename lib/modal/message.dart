import 'package:offline_chat/helper.dart';

class Message {
  String message;
  DateTime time;
  int code;
  String by;
  String ip;

  Message(this.code, this.message, this.time, this.by, this.ip);

  //  0 - Code
  //  1 - sent by
  //  2 - ip address
  //  3 - time
  //  4 - message
  String encodeString() => encode([
        code.toString(),
        by,
        ip,
        time.toString(),
        message,
      ]);

  static Message decodeString(String string) {
    List<String> val = decode(string);
    String message = val[4];

    if (val.length > 5) {
      for (int i = 5; i < val.length; i++) message += X + val[i];
    }
    print("Message: $message");

    int code = int.parse(val[0]);
    String by = val[1];
    String ip = val[2];
    DateTime time = DateTime.tryParse(val[2]);

    return new Message(code, message, time, by, ip);
  }
}

class User {
  int code;
  String name;
  String ip;

  User(this.code, this.name, this.ip);
}
