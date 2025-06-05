import 'package:flutter/material.dart';

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _messageController = TextEditingController();


  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void SendMessage(TextEditingController message) {
    String message = _messageController.text.trim();
    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter a message to send."),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }
    _messageController.clear();
    //upload logic to firebase firestore
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Type a message',
              ),
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          IconButton(
              onPressed: () {
                SendMessage(_messageController);
              },
              icon: Icon(
                Icons.send,
                color: Theme.of(context).colorScheme.primary,
              ),),
        ],
      ),
    );
  }
}
