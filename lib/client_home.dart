import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_chat/chat.dart';
import 'package:offline_chat/helper.dart';
import 'package:offline_chat/message_manager.dart';
import 'package:offline_chat/modal/person.dart';
import 'package:offline_chat/udp/udp.dart';

class ClientHome extends StatefulWidget {
  @override
  _ClientHomeState createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  StreamSubscription<RawSocketEvent> _udpListener;
  bool isHostLoading = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    //  Creates an instance of udp & automatically binds to the IP
    //  Also sets listeners with handlers
    udp = new UDP(ip.address);
    await udp.connect();
    pingHost();
  }

  @override
  void dispose() {
    udp.disconnect();
    super.dispose();
  }

  pingHost() async {
    setState(() => isHostLoading = true);

    for (int i = 0; i < 2; i++) {
      print("Pinging to ${hostIp.address}");

      String message = encode([GET_HOST, ip.address]);
      udp.send(message, hostIp.address);
      await Future.delayed(Duration(seconds: 3));
    }

    setState(() => isHostLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(30.0),
      padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        border: Border.all(
          width: 2.0,
          color: Colors.white,
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 10.0),
            padding: EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2.0,
                  color: Colors.white,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "CONNECT TO",
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: hosts.length > 0
                ? ListView.builder(
                    itemBuilder: (_, __) {
                      List<String> hostKeys = hosts.keys.toList();
                      return Container(
                        margin: EdgeInsets.all(10.0),
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          color: Colors.white12,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.green[600].withOpacity(0.45),
                            borderRadius: BorderRadius.circular(15.0),
                            onTap: () async {
                              Person person =
                                  new Person(CONNECT, name, ip.address);
                              people.clear();
                              people.add(new Person(
                                  CONNECT, hosts[hostKeys[__]], hostKeys[__]));

                              udp.send(
                                person.encodeString(),
                                hostKeys[__],
                              );

                              hosts.clear();
                              isHost = false;

                              hostConnected.value = true;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => Chat(),
                                ),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 15.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    minRadius: 30.0,
                                    child: Text(
                                      hosts[hostKeys[__]][0].toUpperCase(),
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 25.0),
                                  Expanded(
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            child: Text(
                                              hosts[hostKeys[__]],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 20,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          SizedBox(height: 10.0),
                                          Container(
                                            child: Text(
                                              hostKeys[__],
                                              style: TextStyle(
                                                color: Colors.white
                                                    .withOpacity(.75),
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: hosts.length,
                  )
                : isHostLoading && hosts.length == 0
                    ? Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: Text(
                                "No Hosts Found",
                                style: TextStyle(
                                  color: Colors.white60,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.orange,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50.0),
                                onTap: pingHost,
                                child: Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Icon(
                                    Icons.sync,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(50.0),
                              color: Colors.green[700],
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50.0),
                                onTap: () async {
                                  //  Reset ip to host IP
                                  udp.disconnect();

                                  udp = new UDP(ip.address);
                                  await udp.connect();

                                  isHost = true;

                                  //  Navigate to Chat
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => Chat(),
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 10.0, horizontal: 20.0),
                                  child: Text(
                                    "Host Chat",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
