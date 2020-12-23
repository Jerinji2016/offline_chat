import 'package:flutter/material.dart';
import 'package:offline_chat/modal/message.dart';
import 'package:offline_chat/modal/person.dart';
import 'package:offline_chat/utils/helper.dart';

import 'udp/udp.dart';

class SendPrivate extends StatefulWidget {
  final String message;
  SendPrivate(this.message);
  @override
  _SendPrivateState createState() => _SendPrivateState();
}

class _SendPrivateState extends State<SendPrivate> {
  Map<String, Person> privatePeople = new Map();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: (2 * MediaQuery.of(context).size.height) / 3,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        color: Colors.black.withOpacity(0.1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            child: Text(
              "Send Privately to",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            height: 2.0,
            color: Colors.white70,
            margin: EdgeInsets.symmetric(
              vertical: 15.0,
              horizontal: 20.0,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (_, __) {
                return Container(
                  margin: EdgeInsets.symmetric(vertical: 2.0, horizontal: 20.0),
                  child: Material(
                    borderRadius: BorderRadius.circular(8.0),
                    color: privatePeople.containsKey(__.toString())
                        ? Colors.grey.withOpacity(.3)
                        : Colors.transparent,
                    elevation: 10.0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8.0),
                      onTap: () {
                        if (privatePeople.containsKey(__.toString()))
                          privatePeople.remove(__.toString());
                        else
                          privatePeople.putIfAbsent(
                              __.toString(), () => people[__]);

                        setState(() {});
                      },
                      child: Container(
                        height: 60.0,
                        alignment: Alignment.centerLeft,
                        padding: EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          "${people[__].name}\n@\t${people[__].ip.address}",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
              itemCount: people.length,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 10.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.red[600],
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: () => Navigator.pop(context, true),
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Cancel",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 5.0),
                    child: Material(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.green,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10.0),
                        onTap: sendPrivate,
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          alignment: Alignment.center,
                          child: Text(
                            "Send",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  sendPrivate() {
    Message message = new Message(
      MESSAGE,
      widget.message,
      DateTime.now(),
      name,
      (isHost ? hostIp : ip).address,
    );

    privatePeople.forEach((key, value) {
      udp.send(widget.message, value.address);
    });

    messages.value.add(message);

    Navigator.pop(context, false);
  }
}
