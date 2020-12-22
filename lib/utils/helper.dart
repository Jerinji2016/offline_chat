import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_chat/udp/udp.dart';

import '../modal/person.dart';

ValueNotifier<List<dynamic>> messages = new ValueNotifier([]);
UDP udp;

Map<String, String> hosts = new Map();
List<Person> people = new List();

InternetAddress ip;
RawDatagramSocket socket;

final InternetAddress hostIp = InternetAddress(
  "255.255.255.255",
  type: InternetAddressType.IPv4,
);

const int PORT = 8889;
const String X = "#cut#";
const String NAME = "name";

bool isHost = false;
bool isActuallyHost = false;
String name = "John Doe";

List<String> decode(text) => text.split(X);

String encode(List<dynamic> list) => list.join(X);

ValueNotifier<bool> hostConnected = new ValueNotifier(false);

