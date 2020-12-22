import 'dart:io';

import 'package:flutter/material.dart';
import 'package:offline_chat/client_home.dart';
import 'package:offline_chat/utils/helper.dart';
import 'package:offline_chat/host_home.dart';
import 'package:offline_chat/udp/udp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wifi/wifi.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferences pref = await SharedPreferences.getInstance();
  name = pref.getString(NAME) ?? name;

  try {
    ip = InternetAddress(
      await Wifi.ip,
      type: InternetAddressType.IPv4,
    );
    isHost = isActuallyHost = false;
  } catch (e) {
    ip = InternetAddress(
      "255.255.255.255",
      type: InternetAddressType.IPv4,
    );
    isHost = isActuallyHost = true;
  }

  print("Current IP : $ip");

  // RawDatagramSocket.bind(ip, PORT, reuseAddress: true)
  //   ..then(
  //     (RawDatagramSocket udpSocket) {
  //       print("DataGram Socket binded to IP: ${ip.address}");
  //       socket = udpSocket;

  //       socket.broadcastEnabled = true;
  //     },
  //   );

  runApp(
    MaterialApp(
      home: ChatApp(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

class ChatApp extends StatefulWidget {
  @override
  _ChatAppState createState() => _ChatAppState();
}

class _ChatAppState extends State<ChatApp> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _scaleUp, _scaleDown;

  Animation<double> opacityIn(b, e) => Tween<double>(
        begin: 0,
        end: 1,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            b,
            e,
            curve: Curves.ease,
          ),
        ),
      );

  Animation<double> translateIn(b, e) => Tween<double>(
        begin: 30,
        end: 0,
      ).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            b,
            e,
            curve: Curves.ease,
          ),
        ),
      );

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(
        seconds: 5,
      ),
    );

    _scaleUp = Tween<double>(
      begin: 1,
      end: 1.25,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          1 / 8,
          1 / 6,
          curve: Curves.ease,
        ),
      ),
    );

    _scaleDown = Tween<double>(
      begin: 1.25,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(
          1 / 6,
          1 / 3,
          curve: Curves.ease,
        ),
      ),
    );

    _controller.forward(from: 0.0);

    super.initState();
  }

  @override
  dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => Container(
            color: Colors.black,
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Column(
              children: [
                Expanded(
                  flex: 1,
                  child: Opacity(
                    opacity: opacityIn(0.0, 1 / 8).value,
                    child: Transform.translate(
                      offset: Offset(0, translateIn(0.0, 1 / 8).value),
                      child: Transform.translate(
                        offset: Offset(
                          0,
                          Tween<double>(
                            begin:
                                (MediaQuery.of(context).size.height / 2) - 40,
                            end: 0,
                          )
                              .animate(
                                CurvedAnimation(
                                  parent: _controller,
                                  curve: Interval(
                                    1 / 3,
                                    2 / 3,
                                    curve: Curves.ease,
                                  ),
                                ),
                              )
                              .value,
                        ),
                        child: Transform.scale(
                          scale: _scaleUp.value,
                          child: Transform.scale(
                            scale: _scaleDown.value,
                            child: Container(
                              margin: EdgeInsets.only(bottom: 10.0),
                              alignment: Alignment.bottomCenter,
                              child: Text(
                                isActuallyHost
                                    ? "You are the Host"
                                    : "You are the client",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Center(
                    child: Opacity(
                      opacity: opacityIn(0.5, 0.9).value,
                      child: Transform.translate(
                        offset: Offset(0, translateIn(0.5, 0.9).value),
                        child: Container(
                          child: ChangeName(),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Center(
                    child: Opacity(
                      opacity: opacityIn(0.7, 1.0).value,
                      child: Transform.translate(
                        offset: Offset(0, translateIn(0.7, 1.0).value),
                        child: isActuallyHost ? HostHome() : ClientHome(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ChangeName extends StatefulWidget {
  @override
  _ChangeNameState createState() => _ChangeNameState();
}

class _ChangeNameState extends State<ChangeName> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<double> _opacity, _translate;

  bool nameEdit = false;
  TextEditingController _nameController = new TextEditingController();

  @override
  initState() {
    _controller = new AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 700),
      reverseDuration: Duration(milliseconds: 400),
    );

    _opacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    _translate = Tween<double>(begin: 20, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.ease,
      ),
    );

    _controller.forward();
    super.initState();
  }

  @override
  dispose() {
    _nameController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Opacity(
        opacity: _opacity.value,
        child: Transform.translate(
          offset: Offset(
            0,
            _translate.value,
          ),
          child: __,
        ),
      ),
      child: nameEdit ? editName() : displayName(),
    );
  }

  Widget displayName() => Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.transparent,
                onTap: () => _controller.reverse(from: 1.0)
                  ..whenComplete(
                    () => setState(() {
                      nameEdit = true;
                      _controller.forward(from: 0.0);
                    }),
                  ),
                borderRadius: BorderRadius.circular(20.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.edit, color: Colors.white60),
                ),
              ),
            ),
          ],
        ),
      );

  Widget editName() => Container(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: MediaQuery.of(context).size.width / 2.5,
              padding: EdgeInsets.all(10.0),
              child: TextField(
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Enter your name",
                  hintStyle: TextStyle(
                    color: Colors.white30,
                  ),
                ),
                controller: _nameController,
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.circular(50.0),
              color: Colors.green[700],
              child: InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.orange[700],
                onTap: () => _controller.reverse(from: 1.0)
                  ..whenComplete(
                    () async {
                      name = (_nameController.text.trim().length > 0)
                          ? _nameController.text.trim()
                          : name;

                      SharedPreferences pref =
                          await SharedPreferences.getInstance();
                      pref.setString(NAME, name);

                      setState(() {
                        nameEdit = false;
                        _controller.forward(from: 0.0);
                      });
                    },
                  ),
                borderRadius: BorderRadius.circular(50.0),
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  child: Icon(Icons.done, color: Colors.white60),
                ),
              ),
            ),
          ],
        ),
      );
}
