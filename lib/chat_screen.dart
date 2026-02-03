import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../state/app_state.dart';
import '../widgets/message_bubble.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Listen to changes and scroll to the bottom
    final appState = Provider.of<AppState>(context);
    appState.addListener(_scrollToBottom);
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final messages = appState.messages;
    final isLoading = appState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC), // slate-50
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B), // slate-800
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B), // amber-500
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Icon(LucideIcons.scale, color: Colors.white),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dijital Katip',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  'Hukuki Asistan',
                  style: TextStyle(
                    color: Color(0xFF94A3B8), // slate-300
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ],
        ),
        elevation: 4.0,
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeMessage()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: messages.length + (isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isLoading && index == messages.length) {
                        return _buildLoadingIndicator();
                      }
                      return MessageBubble(message: messages[index]);
                    },
                  ),
          ),
          _buildTextInput(isLoading),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    // Welcome message UI remains the same
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(LucideIcons.scale, size: 48, color: Color(0xFFF59E0B)),
            SizedBox(height: 16),
            Text(
              'Hoş geldiniz!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            SizedBox(height: 8),
            Text(
              'Ben Dijital Katip, Türk hukuku konusunda size yardımcı olmak için buradayım. Hukuki sorununuzu anlatın ve sizin için resmi bir dilekçe hazırlayayım.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF475569), height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    // Loading indicator UI remains the same
     return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)), // slate-200
          ),
          child: const Row(
            children: [
              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 12),
              Text('Yanıt hazırlanıyor...'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isLoading,
                style: const TextStyle(fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Ne yapmak istiyorsunuz? Buraya yazın...',
                  hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                  filled: true,
                  fillColor: isLoading ? const Color(0xFFF1F5F9) : Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFFCBD5E1), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color(0xFF0F172A), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                ),
                onSubmitted: isLoading ? null : _handleSubmitted,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading || _textController.text.trim().isEmpty
                  ? null
                  : () => _handleSubmitted(_textController.text),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
              child: const Icon(LucideIcons.send),
            ),
          ],
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    context.read<AppState>().sendMessage(text);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    Provider.of<AppState>(context, listen: false).removeListener(_scrollToBottom);
    super.dispose();
  }
}
