//

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:j_bluetooth_example/models/chat_message.dart';

class ChatMessageTile extends StatelessWidget {
  const ChatMessageTile({
    super.key,
    required this.message,
  });
  final ChatMessage message;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Align(
        alignment:
            (message.isFromLocalUser ? Alignment.topLeft : Alignment.topRight),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: message.isFromLocalUser
                ? Colors.grey.shade200
                : Colors.grey.shade300,
          ),
          padding: const EdgeInsets.all(16),
          child: Text(
            message.message,
            style: textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
}
