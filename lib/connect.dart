import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_chat/helper.dart';

class Connect extends StatefulWidget {
  @override
  _ConnectState createState() => _ConnectState();
}

class _ConnectState extends State<Connect> {
  bool isConnected = false;

  @override
  initState() {
    initConnect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.blueGrey[900],
        centerTitle: true,
        title: Text("Connect"),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        child: ListView.builder(
          itemBuilder: (_, __) {
            return Container(
              height: 40,
              width: size.width,
              margin: EdgeInsets.all(10.0),
              color: Colors.grey,
            );
          },
          itemCount: 10,
        ),
      ),
    );
  }

  initConnect() async {


    RawDatagramSocket.bind(ip, PORT, reuseAddress: true)
      ..then(
        (RawDatagramSocket udpSocket) {
          print("DataGram Socket binded to IP: ${ip.address}");
          socket = udpSocket;

          socket.broadcastEnabled = true;

          socket.listen((e) {
          Datagram dg = socket.receive();
          if (dg != null) {
            String receivedText = String.fromCharCodes(dg.data);
            print("Received from Host:\n$receivedText");
            
            // print(receivedText);
          }
        });

          // String d = "host#cut#${ip.address}#cut#$HOST_CONN";

          // List<int> data = utf8.encode(d);
          // socket.send(data, hostIp, PORT);
          // print("Sent test ping $d");
        },
      );
  }

  void pingConnection() async {}
}
