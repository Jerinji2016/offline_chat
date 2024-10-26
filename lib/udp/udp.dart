import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../modal/message.dart';
import '../modal/person.dart';
import '../utils/helper.dart';

enum ConnectionCode {
  ///  Code to get host
  getHost(111),

  ///  Code to accept client request before showing to client
  connect(112),

  ///  Code to send message
  message(113),

  ///  Code user joined
  userJoined(118),

  ///  Code user left
  userLeft(119),

  ///  Response to GET_HOST by host
  hostResponse(114),

  ///  Host Kill
  hostKilled(120);

  const ConnectionCode(this.code);

  final int code;
}

class UDP {
  UDP(this.address) : ip = InternetAddress(address, type: InternetAddressType.IPv4);

  String address;
  InternetAddress ip;
  RawDatagramSocket? socket;

  void connect() {
    RawDatagramSocket.bind(ip, port).then((RawDatagramSocket udpSocket) {
      socket = udpSocket;
      socket?.broadcastEnabled = true;

      debugPrint('Datagram socket binded to: ${ip.address}');
      setListener();
    });
  }

  void setListener() {
    socket?.listen((RawSocketEvent event) {
      final dg = socket?.receive();
      if (dg != null) {
        handleData(dg);
      }
    });
  }

  void disconnect() {
    socket?.close();
    debugPrint('Datagram socket on ${ip.address} closed');
  }

  //  Send message to an individual IP
  void send(String message, String toAddress) {
    debugPrint('Sending: ${decode(message)}');
    final data = utf8.encode(message);

    socket?.send(
      data,
      InternetAddress(toAddress, type: InternetAddressType.IPv4),
      port,
    );
  }

  //  Send message to a list of IP address model in PERSON object
  void broadcast(String message, List<Person> addresses) {
    debugPrint('Broadcasting: ${decode(message)}');
    final data = utf8.encode(message);

    for (final person in addresses) {
      socket?.send(data, person.ip, port);
    }
  }

  void handleData(Datagram dg) {
    final receivedText = String.fromCharCodes(dg.data);
    final received = receivedText.split(delimiter);
    debugPrint('Received from X: $received');

    final code = ConnectionCode.values.elementAt(int.parse(received[0]));

    switch (code) {
      case ConnectionCode.getHost:
        hostResponse(received);
      case ConnectionCode.hostResponse:
        addHost(receivedText);
      case ConnectionCode.connect:
        isHost ? broadcastNewPerson(receivedText) : addNewPerson(receivedText);
      case ConnectionCode.message:
        newMessage(receivedText);
      case ConnectionCode.userJoined:
      case ConnectionCode.userLeft:
      case ConnectionCode.hostKilled:
    }
  }

  void hostResponse(List<String> received) {
    final message = Person(
      ConnectionCode.hostResponse.index,
      name,
      hostIp.address,
    ).encodeString();
    socket?.send(utf8.encode(message), InternetAddress(received[1]), port);
  }

  void addHost(String received) {
    final p = Person.decodeString(received);
    hosts.putIfAbsent(p.address, () => p.name);
  }

  void broadcastNewPerson(String message) {
    debugPrint('New Person: ${decode(message)}');

    for (final person in people) {
      socket?.send(utf8.encode(message), person.ip, port);
    }
    addNewPerson(message);
  }

  void addNewPerson(String message) {
    var isMe = false;

    final person = Person.decodeString(message);

    for (final person in people) {
      debugPrint('Element Address: ${person.address}\nMy Address: ${ip.address}');

      if (isHost && person.address == hostIp.address) isMe = true;
      if (person.address == ip.address) isMe = true;
      if (person.address == person.address) isMe = true;
    }

    if (!isMe) {
      debugPrint('Adding ${person.address}');
      people.add(person);
      messages.value.add(person);
    }
  }

  void newMessage(String message) {
    messages.value = [
      ...messages.value,
      Message.decodeString(message),
    ];
  }

  void hostKilled() {
    hostConnected.value = false;
  }
}
