import 'dart:async';

import 'package:flutter/material.dart';
import 'chat.dart';
import 'modal/person.dart';
import 'udp/udp.dart';
import 'utils/helper.dart';

class ClientHome extends StatefulWidget {
  const ClientHome({super.key});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  bool isHostLoading = false;

  @override
  void initState() {
    super.initState();
    udp = UDP(ip?.address ?? '');
    udp?.connect();
    pingHost();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(30),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          width: 2,
          color: Colors.white,
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 2,
                  color: Colors.white,
                ),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'CONNECT TO',
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
            child: hosts.isNotEmpty
                ? ListView.builder(
                    itemBuilder: (context, index) {
                      final hostKeys = hosts.keys.toList();
                      return Container(
                        margin: const EdgeInsets.all(10),
                        child: Material(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          color: Colors.white12,
                          child: InkWell(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.green.shade600.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(15),
                            onTap: () async {
                              final person = Person(ConnectionCode.connect.index, name, ip?.address ?? '');
                              people
                                ..clear()
                                ..add(
                                  Person(
                                    ConnectionCode.connect.index,
                                    hosts[hostKeys[index]] ?? '',
                                    hostKeys[index],
                                  ),
                                );

                              udp?.send(
                                person.encodeString(),
                                hostKeys[index],
                              );

                              hosts.clear();
                              isHost = false;

                              hostConnected.value = true;

                              if (mounted) {
                                unawaited(
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const ChatScreen(),
                                    ),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    minRadius: 30,
                                    child: Text(
                                      hosts[hostKeys[index]]?[0].toUpperCase() ?? 'unknown host',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 24,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 25),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          hosts[hostKeys[index]] ?? '',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          hostKeys[index],
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(.75),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: hosts.length,
                  )
                : isHostLoading && hosts.isEmpty
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.green),
                        ),
                      )
                    : Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No Hosts Found',
                              style: TextStyle(
                                color: Colors.white60,
                                fontStyle: FontStyle.italic,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.orange,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: pingHost,
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  child: const Icon(
                                    Icons.sync,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Material(
                              borderRadius: BorderRadius.circular(50),
                              color: Colors.green[700],
                              child: InkWell(
                                borderRadius: BorderRadius.circular(50),
                                onTap: () async {
                                  //  Reset ip to host IP
                                  udp?.disconnect();

                                  udp = UDP(ip?.address ?? '');
                                  udp?.connect();

                                  isHost = true;

                                  //  Navigate to Chat
                                  if (context.mounted) {
                                    unawaited(
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const ChatScreen(),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                                  child: const Text(
                                    'Host Chat',
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

  Future<void> pingHost() async {
    setState(() => isHostLoading = true);

    for (var i = 0; i < 2; i++) {
      debugPrint('Pinging to ${hostIp.address}');

      final message = encode([ConnectionCode.getHost, ip?.address]);
      udp?.send(message, hostIp.address);
      await Future<void>.delayed(const Duration(seconds: 3));
    }

    setState(() => isHostLoading = false);
  }

  @override
  void dispose() {
    udp?.disconnect();
    super.dispose();
  }
}
