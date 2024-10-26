import 'package:flutter/material.dart';

import 'chat.dart';
import 'udp/udp.dart';
import 'utils/helper.dart';

class HostHome extends StatefulWidget {
  const HostHome({super.key});

  @override
  State<HostHome> createState() => _HostHomeState();
}

class _HostHomeState extends State<HostHome> {
  @override
  void initState() {
    super.initState();
    udp = UDP(ip?.address ?? '');
    udp?.connect();
  }

  @override
  void dispose() {
    udp?.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Hosting on IP : ${hostIp.address}\nPort : $port',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            height: 1.8,
          ),
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              alignment: Alignment.center,
              child: const Text(
                'Go to chat',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Stack(
              children: [
                Material(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50),
                    side: const BorderSide(
                      width: 2,
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(50),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (_) => const ChatScreen(),
                      ),
                    ),
                    highlightColor: Colors.orange,
                    splashColor: Colors.transparent,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      child: const Icon(
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
                      if (message.isEmpty) {
                        return const SizedBox.shrink();
                      } else {
                        return Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.orange,
                          ),
                          width: 24,
                          height: 24,
                          child: Text(
                            '${message.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
