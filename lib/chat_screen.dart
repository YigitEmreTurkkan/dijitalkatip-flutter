import 'package:flutter/material.dart';
import 'package:lucide_flutter/lucide_flutter.dart';
import 'package:provider/provider.dart';
import '../models/message.dart';
import '../state/app_state.dart';
import '../widgets/message_bubble.dart';
import '../theme.dart';

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
    final hasParentAppBar = Scaffold.maybeOf(context)?.hasAppBar ?? false;

    return Scaffold(
      appBar: hasParentAppBar ? null : _buildAppBar(),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildWelcomeMessage(context)
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
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

  AppBar _buildAppBar() {
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(LucideIcons.scale, color: Theme.of(context).colorScheme.onSecondary),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Dijital Katip',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                'Hukuki Asistan',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.7),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final isNarrow = MediaQuery.of(context).size.width < 600;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              LucideIcons.scale,
              size: isNarrow ? 40 : 48,
              color: Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(height: 24),
            Text(
              '3 adımda dijital katip:',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '1) Buraya, yani SOHBET ekranına, yaşadığınız hukuki olayı normal Türkçe ile anlatın.\n\n'
              '2) Üstteki sekmelerden "Belge / PDF" sekmesine geçin. Dilekçenizin güncel halini orada göreceksiniz.\n\n'
              '3) Belge ekranının sağ alt köşesindeki "PDF İndir" butonuna basarak dilekçenizi PDF olarak indirin.\n\n'
              'Takıldığınızda bana "Bu uygulamayı nasıl kullanırım?" diye sorabilirsiniz, adım adım tekrar anlatırım.',
              textAlign: TextAlign.left,
              style: textTheme.bodyLarge?.copyWith(color: mutedTextColor, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: MessageBubble(message: Message(id: 'loading', role: MessageRole.assistant, content: '...', createdAt: DateTime.now())),
    );
  }

  Widget _buildTextInput(bool isLoading) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                enabled: !isLoading,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'Bir mesaj yazın...',
                ),
                minLines: 1,
                maxLines: 5,
                onSubmitted: isLoading ? null : _handleSubmitted,
                onChanged: (_) {
                  // Rebuild to update send button enabled/disabled state
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: isLoading || _textController.text.trim().isEmpty ? null : () => _handleSubmitted(_textController.text),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
                shape: const CircleBorder(),
              ),
              child: isLoading
                  ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(LucideIcons.send, size: 24),
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
    setState(() {}); // Clear send button disabled/enabled state
    FocusScope.of(context).unfocus();
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    Provider.of<AppState>(context, listen: false).removeListener(_scrollToBottom);
    super.dispose();
  }
}
