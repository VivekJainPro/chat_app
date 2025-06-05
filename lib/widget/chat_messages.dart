import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10, // Replace with your message count
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Message $index'), // Replace with your message content
            subtitle: Text('User $index'), // Replace with the sender's name
          );
        },
      ),
    );
  }
}