import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:ui';

class ChatbotOverlay extends StatefulWidget {
  const ChatbotOverlay({super.key});

  @override
  State<ChatbotOverlay> createState() => _ChatbotOverlayState();
}

class _ChatbotOverlayState extends State<ChatbotOverlay> {
  Offset bubblePosition = const Offset(20, 500);
  bool isWebViewVisible = false;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString('''
        <!DOCTYPE html>
        <html>
          <head>
            <meta charset="UTF-8" />
            <script>
              window.chatbaseConfig = {
                chatbotId: "xLVdg_ABBMqe_uEjZHUFf"
              };
            </script>
            <script src="https://www.chatbase.co/embed.min.js" defer></script>
            <style>
              html, body {
                margin: 0;
                height: 100%;
                background-color: white;
              }
            </style>
          </head>
          <body></body>
        </html>
      ''');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // WebView shown when tapped
        if (isWebViewVisible)
          Positioned.fill(
            child: Container(
              color: Colors.white,
              child: WebViewWidget(controller: _controller),
            ),
          ),

        // Floating Chat Bubble
        Positioned(
          left: bubblePosition.dx,
          top: bubblePosition.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                bubblePosition += details.delta;
              });
            },
            onTap: () {
              setState(() {
                isWebViewVisible = !isWebViewVisible;
              });
            },
            child: const CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage('assets/chat_icon.png'),
            ),
          ),
        ),
      ],
    );
  }
}
