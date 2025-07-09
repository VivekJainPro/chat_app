import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void SendMessage() async {
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

    final user = FirebaseAuth.instance.currentUser!;
    print("heres the user $user");

    final userInfo = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    print("heres the userInfo ${userInfo.data()}");

    //upload logic to firebase firestore
    db.collection('chats').add({
      'username': userInfo.data()!['username'],
      'chat': message,
      'userId': user.uid,
      'timestamp': Timestamp.now(),
      'userImage': userInfo
          .data()!['image_url'], // Use displayName or fallback to 'Anonymous'
    });
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.primary.withAlpha(30),
                hintText: 'Type a message',
              ),
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (string) {
                SendMessage();
              },
            ),
          ),
          IconButton(
            onPressed: () {
              SendMessage();
            },
            icon: Icon(
              Icons.send,
              color: Theme.of(context).colorScheme.primary.withGreen(255),
            ),
          ),
        ],
      ),
    );
  }
}
