import 'dart:ui';

import 'package:flutter/material.dart';

import 'modal/message.dart';
import 'modal/person.dart';
import 'people_drawer.dart';
import 'send_private.dart';
import 'udp/udp.dart';
import 'utils/helper.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Host on ${hostIp.address}'),
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
              const Expanded(
                child: Terminal(),
              ),
              Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      flex: 10,
                      child: TextField(
                        style: const TextStyle(color: Colors.white),
                        controller: _messageController,
                        decoration: const InputDecoration(
                          hintText: 'Enter message',
                          hintStyle: TextStyle(color: Colors.white54),
                        ),
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: sendMessage,
                      onLongPress: sendPrivate,
                      child: const Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> sendMessage() async {
    final text = _messageController.text.trim();

    if (text.isEmpty) return;

    final message = Message(
      ConnectionCode.message.index,
      text,
      DateTime.now(),
      name,
      (isHost ? hostIp : ip)?.address ?? 'no-address',
    );

    udp?.broadcast(message.encodeString(), people);
    messages.value.add(message);
    setState(() {});

    _messageController.clear();
  }

  Future<void> sendPrivate() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    FocusScope.of(context).unfocus();
    final canceled = await showDialog<bool?>(
          context: context,
          barrierColor: Colors.transparent,
          builder: (_) => Dialog(
            elevation: 10,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: 2,
                sigmaY: 2,
              ),
              child: SendPrivate(text),
            ),
          ),
        ) ??
        true;

    if (!canceled) _messageController.text = '';
    setState(() {});
  }

  @override
  void dispose() {
    hostConnected.removeListener(() {});
    super.dispose();
  }
}

class Terminal extends StatefulWidget {
  const Terminal({super.key});

  @override
  State<Terminal> createState() => _TerminalState();
}

class _TerminalState extends State<Terminal> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    hostListener();
  }

  void hostListener() {
    hostConnected.addListener(() {
      if (!hostConnected.value) {
        debugPrint('Host not available');
      }
      Navigator.of(context).pop();
    });

    messages.addListener(() {
      debugPrint('New Message');
      _scrollController.animateTo(
        1,
        duration: const Duration(seconds: 1),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ValueListenableBuilder(
        valueListenable: messages,
        builder: (_, message, ___) => ListView.builder(
          reverse: true,
          controller: _scrollController,
          itemBuilder: (_, __) {
            final index = message.length - 1 - __;
            return (message[index] is Person)
                ? Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      '${message[index].name} joined the chat',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : (message[index] is Message)
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: 10,
                        ),
                        alignment:
                            ((isHost && message[index].ip == hostIp.address) || (message[index].ip == ip?.address))
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment:
                              ((isHost && message[index].ip == hostIp.address) || (message[index].ip == ip?.address))
                                  ? CrossAxisAlignment.end
                                  : CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 3),
                              margin: const EdgeInsets.symmetric(vertical: 3),
                              decoration: const BoxDecoration(
                                border: Border(
                                  bottom: BorderSide(
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                              child: Text(
                                '${message[index].by}@${message[index].ip}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Container(
                              child: Text(
                                message[index].message.toString(),
                                style: const TextStyle(
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
                        margin: const EdgeInsets.symmetric(vertical: 5),
                        color: Colors.red,
                        height: 10,
                      );
          },
          itemCount: message.length,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
