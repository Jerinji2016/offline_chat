import 'dart:convert';
import 'dart:io';

import 'package:offline_chat/utils/helper.dart';
import 'package:offline_chat/modal/message.dart';
import 'package:offline_chat/modal/person.dart';

///  Code to get host
const int GET_HOST = 111;

///  Code to accept client request before showing to client
const int CONNECT = 112;

///  Code to send message
const int MESSAGE = 113;

///  Code user joined
const int USER_JOINED = 118;

///  Code user left
const int USER_LEFT = 119;

///  Response to GET_HOST by host
const int HOST_RESPONSE = 114;

///  Host Kill
const int HOST_KILLED = 120;

class UDP {
  String address;
  InternetAddress ip;
  RawDatagramSocket socket;

  UDP(this.address) : super() {
    this.ip = new InternetAddress(address, type: InternetAddressType.IPv4);
  }

  connect() {
    RawDatagramSocket.bind(ip, PORT).then((RawDatagramSocket udpSocket) {
      this.socket = udpSocket;
      this.socket.broadcastEnabled = true;

      print("Datagram socket binded to: ${ip.address}");
      setListener();
    });
  }

  setListener() {
    socket.listen((RawSocketEvent event) {
      Datagram dg = socket.receive();
      if (dg != null) {
        handleData(dg);
      }
    });
  }

  disconnect() {
    socket.close();
    print("Datagram socket on ${ip.address} closed");
  }

  //  Send message to an individual IP
  send(String message, String toAddress) {
    print("Sending: ${decode(message)}");
    List<int> data = utf8.encode(message);

    socket.send(
      data,
      InternetAddress(toAddress, type: InternetAddressType.IPv4),
      PORT,
    );
  }

  //  Send message to a list of IP address model in PERSON object
  broadcast(String message, List<Person> addresses) {
    print("Broadcasting: ${decode(message)}");
    List<int> data = utf8.encode(message);

    addresses.forEach((person) {
      socket.send(data, person.ip, PORT);
    });
  }

  void handleData(Datagram dg) {
    String receivedText = String.fromCharCodes(dg.data);
    List<String> received = receivedText.split(X);
    print("Received from X: $received");

    int code = int.parse(received[0]);

    switch (code) {
      case GET_HOST:
        hostResponse(received);
        break;
      case HOST_RESPONSE:
        addHost(receivedText);
        break;
      case CONNECT:
        isHost ? broadcastNewPerson(receivedText) : addNewperson(receivedText);
        break;
      case MESSAGE:
        newMessage(receivedText);
        break;
      case USER_JOINED:
        break;
      case USER_LEFT:
        break;
      case HOST_KILLED:
        break;
      default:
        print("Error code not found");
    }
  }

  hostResponse(List<String> received) {
    String message =
        new Person(HOST_RESPONSE, name, hostIp.address).encodeString();
    socket.send(utf8.encode(message), InternetAddress(received[1]), PORT);
  }

  addHost(String received) {
    Person p = Person.decodeString(received);
    hosts.putIfAbsent(p.address, () => p.name);
  }

  broadcastNewPerson(String message) {
    print("New Person: ${decode(message)}");

    people.forEach((person) {
      socket.send(utf8.encode(message), person.ip, PORT);
    });
    addNewperson(message);
  }

  addNewperson(String message) {
    bool isMe = false;

    Person person = Person.decodeString(message);

    people.forEach((element) {
      print("Element Address: ${element.address}\nMy Address: ${ip.address}");

      if (isHost && person.address == hostIp.address) isMe = true;
      if (person.address == ip.address) isMe = true;
      if (element.address == person.address) isMe = true;
    });

    if (!isMe) {
      print("Adding ${person.address}");
      people.add(person);
      messages.value.add(person);
    }
  }

  newMessage(String message) {
    messages.value.add(Message.decodeString(message));
    messages.notifyListeners();
  }

  hostKilled() {
    hostConnected.value = false;
    hostConnected.notifyListeners();
  }
}
