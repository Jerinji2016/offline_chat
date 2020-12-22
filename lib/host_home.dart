import 'package:flutter/material.dart';
import 'package:offline_chat/chat.dart';
import 'package:offline_chat/utils/helper.dart';
import 'package:offline_chat/udp/udp.dart';

class HostHome extends StatefulWidget {
  @override
  _HostHomeState createState() => _HostHomeState();
}

class _HostHomeState extends State<HostHome> {
  @override
  initState() {
    init();
    super.initState();
  }

  init() async {
    udp = new UDP(ip.address);
    await udp.connect();
  }

  @override
  dispose() {
    udp.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            child: Text(
              "Hosting on IP : ${hostIp.address}\nPort : $PORT",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                height: 1.8,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  "Go to chat",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Stack(
                children: [
                  Material(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                      side: BorderSide(
                        width: 2.0,
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(50.0),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Chat(),
                        ),
                      ),
                      highlightColor: Colors.orange,
                      splashColor: Colors.transparent,
                      child: Container(
                        padding: EdgeInsets.all(20.0),
                        child: Icon(
                          Icons.keyboard_arrow_right,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: ValueListenableBuilder(
                      valueListenable: messages,
                      builder: (_, message, ___) {
                        return ((message.length ?? 0) == 0)
                            ? SizedBox(
                                height: 0,
                                width: 0,
                              )
                            : Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20.0),
                                  color: Colors.orange,
                                ),
                                width: 24.0,
                                height: 24.0,
                                child: Text(
                                  "${message.length ?? 0}",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
