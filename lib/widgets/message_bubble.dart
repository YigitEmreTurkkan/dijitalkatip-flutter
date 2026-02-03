import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.role == MessageRole.user;
    return Row(
      mainAxisAlignment: isUserMessage ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
          child: Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: isUserMessage ? const Color(0xFF1E293B) : Colors.white, // User: slate-800, Assistant: white
              borderRadius: BorderRadius.circular(20),
              border: isUserMessage ? null : Border.all(color: const Color(0xFFE2E8F0)), // Assistant: slate-200
              boxShadow: isUserMessage
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Text(
              message.content,
              style: TextStyle(
                fontSize: 16,
                color: isUserMessage ? Colors.white : const Color(0xFF1E293B), // User: white, Assistant: slate-800
                height: 1.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
