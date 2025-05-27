//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:j_bluetooth/j_bluetooth.dart';
import 'package:j_bluetooth_example/models/chat_message.dart';

import 'models/chat_message_tile.dart';

const Color _background = Color(0xFFF5F5F5);

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
    required this.device,
  });

  final ConnectedDevice device;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final myController = TextEditingController();
  StreamSubscription<String>? _incomingMessagesSubscription;
  List<ChatMessage> messages = [];

  @override
  void initState() {
    super.initState();
    initMessages();
  }

  @override
  void dispose() {
    _incomingMessagesSubscription?.cancel();
    super.dispose();
  }

  void initMessages() {
    final jafraBluetooth = JBluetooth();
    _incomingMessagesSubscription =
        jafraBluetooth.incomingMessages().listen((event) {
      final message = ChatMessage(
        message: event,
        isFromLocalUser: false,
      );

      messages.add(message);
      setState(() {});
    });
  }

  // @override
  // void dispose() {
  //   _incomingMessagesSubscription?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat screen'),
      ),
      body: Stack(
        children: <Widget>[
          _buildMessages(context),
          _buildSending(context),
        ],
      ),
    );
  }

  Widget _buildMessages(BuildContext context) {
    return ListView.builder(
      itemCount: messages.length,
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 10, bottom: 10),
      itemBuilder: (context, index) {
        return ChatMessageTile(message: messages[index]);
      },
    );
  }

  Widget _buildSending(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Align(
      alignment: Alignment.bottomLeft,
      child: Material(
        color: Colors.white,
        elevation: 4,
        child: Container(
          padding:
              const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
          width: double.infinity,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: _background,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      // isDense: true,
                      hintText: "Type your message here ...",
                      hintStyle: textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                      ),
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.attach_file,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    controller: myController,
                  ),
                ),
              ),
              const SizedBox(
                width: 15,
              ),
              _buildSendButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSendButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {},
      elevation: 0,
      backgroundColor: Colors.green,
      child: const Icon(
        Icons.send,
        // size: 18,
      ),
    );
  }
}
