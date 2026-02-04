import 'package:flutter/material.dart';
import '../models/message.dart';
import '../theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.role == MessageRole.user;
    final isTyping = message.id == 'loading';
    final theme = Theme.of(context);

    final alignment = isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        crossAxisAlignment: alignment,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
            decoration: BoxDecoration(
              color: isUserMessage ? theme.colorScheme.primary : theme.colorScheme.surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: isUserMessage ? const Radius.circular(20) : const Radius.circular(4),
                bottomRight: isUserMessage ? const Radius.circular(4) : const Radius.circular(20),
              ),
              boxShadow: [
                if (!isUserMessage)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  )
              ],
            ),
            child: isTyping ? _buildTypingIndicator(context) : _buildMessageContent(context, isUserMessage),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context, bool isUserMessage) {
    return Text(
      message.content,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: isUserMessage ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
        height: 1.5,
      ),
    );
  }

  Widget _buildTypingIndicator(BuildContext context) {
    return const SizedBox(
      height: 24, // Matches the approximate height of text
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _TypingDot(),
          SizedBox(width: 4),
          _TypingDot(delay: Duration(milliseconds: 200)),
          SizedBox(width: 4),
          _TypingDot(delay: Duration(milliseconds: 400)),
        ],
      ),
    );
  }
}

// Animated dot for the typing indicator
class _TypingDot extends StatefulWidget {
  final Duration delay;
  const _TypingDot({this.delay = Duration.zero});

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          _controller.forward();
        }
      });

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_controller),
      child: const CircleAvatar(
        radius: 4,
        backgroundColor: mutedTextColor,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
