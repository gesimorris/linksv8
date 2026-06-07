import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Theme Constants (Matched to your HomeScreen)
  static const Color kBackground = Color(0xFFFDFCF9);
  static const Color kPrimary = Color(0xFFFF5C4D);
  static const Color kSecondary = Color(0xFF00D2FF);
  static const Color kDark = Color(0xFF1A1A1A);

  final messageController = TextEditingController();
  final List<Map<String, dynamic>> messages = [
    {'text': 'hey everyone! excited for paint night', 'mine': false, 'name': 'Marcus'},
    {'text': 'same!! first time going', 'mine': false, 'name': 'Sofia'},
    {'text': 'should we meet outside first?', 'mine': true, 'name': 'You'},
    {'text': 'yes! 6:45 outside the venue?', 'mine': false, 'name': 'Marcus'},
    {'text': 'see you all there!', 'mine': false, 'name': 'Marcus'},
  ];

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      messages.add({'text': text, 'mine': true, 'name': 'You'});
      messageController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground, // Matches Home
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.go('/groups'),
                    child: const Icon(Icons.arrow_back_ios_new, size: 20, color: kDark),
                  ),
                  const SizedBox(width: 14),
                  const CircleAvatar(
                    radius: 20,
                    backgroundColor: kDark,
                    child: Text('PA', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Paint Night crew', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: kDark)),
                        Text('3 members · Active now', style: TextStyle(fontSize: 11, color: Colors.black26, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.black26),
                ],
              ),
            ),

            // --- CHAT MESSAGES ---
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: messages.length,
                itemBuilder: (context, i) {
                  final msg = messages[i];
                  final isMine = msg['mine'] as bool;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        if (!isMine) 
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 4),
                            child: Text(msg['name'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black26)),
                          ),
                        Row(
                          mainAxisAlignment: isMine ? MainAxisAlignment.end : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            if (!isMine) ...[
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: kSecondary.withOpacity(0.1),
                                child: Text((msg['name'] as String)[0], style: const TextStyle(fontSize: 11, color: kSecondary, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Container(
                              constraints: const BoxConstraints(maxWidth: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isMine ? kPrimary : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(22),
                                  topRight: const Radius.circular(22),
                                  bottomLeft: Radius.circular(isMine ? 22 : 4),
                                  bottomRight: Radius.circular(isMine ? 4 : 22),
                                ),
                                boxShadow: [
                                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                                ],
                              ),
                              child: Text(
                                msg['text'] as String,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isMine ? Colors.white : kDark,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // --- INPUT AREA ---
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.black.withOpacity(0.05), width: 1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: kBackground,
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: TextField(
                        controller: messageController,
                        style: const TextStyle(color: kDark, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Type a message...',
                          hintStyle: TextStyle(color: Colors.black26),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: kPrimary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: kPrimary, blurRadius: 10, spreadRadius: -5, offset: Offset(0, 4))
                        ],
                      ),
                      child: const Icon(Icons.arrow_upward, size: 20, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}