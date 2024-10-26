import 'dart:io';

import 'package:flutter/material.dart';

import '../modal/person.dart';
import '../udp/udp.dart';

ValueNotifier<List<dynamic>> messages = ValueNotifier([]);
UDP? udp;

final hosts = <String, String>{};
final people = <Person>[];

InternetAddress? ip;
RawDatagramSocket? socket;

final InternetAddress hostIp = InternetAddress(
  '255.255.255.255',
  type: InternetAddressType.IPv4,
);

const port = 8889;
const delimiter = '#cut#';
const nameKey = 'name';

bool isHost = false;
bool isActuallyHost = false;
String name = 'John Doe';

List<String> decode(String text) => text.split(delimiter);

String encode(List<dynamic> list) => list.join(delimiter);

ValueNotifier<bool> hostConnected = ValueNotifier(false);
