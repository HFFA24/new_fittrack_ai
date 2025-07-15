// chatbase_screen.dart
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ChatbaseScreen extends StatefulWidget {
  final String userId;
  final String userHash;

  const ChatbaseScreen({
    required this.userId,
    required this.userHash,
    super.key,
  });

  @override
  State<ChatbaseScreen> createState() => _ChatbaseScreenState();
}

class _ChatbaseScreenState extends State<ChatbaseScreen> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final html =
        '''
    <html><head></head><body>
    <script>
      window.chatbaseUserConfig = {
        user_id: '${widget.userId}',
        user_hash: '${widget.userHash}',
        user_metadata: { name: 'Helena', email: 'helenafoba.cuib@gmail.com' }
      };
    </script>
    <script src="https://cdn.chatbase.co/chatbase.js"></script>
    <script>
      chatbase("init", { chatbot_id: "xLVdg_ABBMqe_uEjZHUFf" });
    </script>
    </body></html>
    ''';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(html);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("AI Coach Chat")),
      body: WebViewWidget(controller: _controller),
    );
  }
}
