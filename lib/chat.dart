import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:offline_chat/send_private.dart';
import 'package:offline_chat/utils/helper.dart';
import 'package:offline_chat/utils/message_manager.dart';
import 'package:offline_chat/modal/message.dart';
import 'package:offline_chat/people_drawer.dart';

import 'modal/person.dart';

class Chat extends StatefulWidget {
  @override
  _ChatState createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  TextEditingController _messageController = TextEditingController();
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    hostConnected.removeListener(() {});
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Host on ${hostIp.address}"),
          centerTitle: true,
          backgroundColor: Colors.black,
        ),
        endDrawer: PeopleDrawer(),
        body: Container(
          color: Colors.black,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Expanded(
                child: Terminal(),
              ),
              Container(
                padding: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: "Enter message",
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    Spacer(
                      flex: 1,
                    ),
                    FlatButton(
                      color: Colors.green,
                      onPressed: sendMessage,
                      onLongPress: sendPrivate,
                      child: Text(
                        "Send",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void sendMessage() async {
    String text = _messageController.text.trim();

    if (text.isEmpty) return;

    Message message = new Message(
      MESSAGE,
      text,
      DateTime.now(),
      name,
      (isHost ? hostIp : ip).address,
    );

    udp.broadcast(message.encodeString(), people);
    messages.value.add(message);
    setState(() {});

    _messageController.text = "";
  }

  void sendPrivate() async {
    String text = _messageController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    bool canceled = await showDialog(
          context: context,
          barrierColor: Colors.transparent,
          barrierDismissible: true,
          builder: (_) => Dialog(
            elevation: 10.0,
            child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 2.0,
                  sigmaY: 2.0,
                ),
                child: SendPrivate(text)),
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          ),
        ) ??
        true;

    if (!canceled) _messageController.text = "";
    setState(() {});
  }
}

class Terminal extends StatefulWidget {
  @override
  _TerminalState createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  ScrollController _scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    hostListener();
  }

  @override
  dispose() {
    messages.value.length = 0;
    messages.notifyListeners();

    super.dispose();
  }

  hostListener() {
    hostConnected.addListener(() {
      if (!hostConnected.value) {
        print("Host not available");
      }
      Navigator.of(context).pop();
    });

    messages.addListener(() {
      print("New Message");
      _scrollController?.animateTo(
        1,
        duration: Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      child: ValueListenableBuilder(
        valueListenable: messages,
        builder: (_, message, ___) => ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemBuilder: (_, __) {
            int index = message.length - 1 - __;
            return (message[index] is Person)
                ? Container(
                    alignment: Alignment.center,
                    padding: EdgeInsets.symmetric(vertical: 10.0),
                    child: Text(
                      "${message[index].name} joined the chat",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : (message[index] is Message)
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 10.0,
                          horizontal: 10.0,
                        ),
                        alignment:
                            ((isHost && message[index].ip == hostIp.address) ||
                                    (message[index].ip == ip.address))
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: ((isHost &&
                                      message[index].ip == hostIp.address) ||
                                  (message[index].ip == ip.address))
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(vertical: 3.0),
                              margin: EdgeInsets.symmetric(vertical: 3.0),
                              decoration: BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    width: 1.0,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              child: Text(
                                "${message[index].by}@${message[index].ip}",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                message[index].message,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(vertical: 5.0),
                        color: Colors.red,
                        height: 10.0,
                      );
          },
          itemCount: message.length,
        ),
      ),
    );
  }
}
