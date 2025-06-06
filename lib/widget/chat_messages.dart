import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatelessWidget {
  const ChatMessages({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection('chats').orderBy('timestamp',descending: true).snapshots(),
        builder: (ctx, chatSnapShots) {
          if (chatSnapShots.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (chatSnapShots.hasError) {
            return const Center(
              child: Text("Something went wrong!"),
            );
          }
          final chatDocs = chatSnapShots.data!.docs;
          return Expanded(
            
            child: ListView.builder(
              reverse: true,
              itemCount: chatDocs.length,
              itemBuilder: (ctx, index) {
                final chatData = chatDocs[index].data();
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                  child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(
                          chatData['userImage'] ?? 
                          'https://www.gravatar.com/avatar',),
                      ),
                      title: Text(chatData['userId']),
                      subtitle: Text(chatData['chat'])),
                );
              },
            ),
          );
        });
  }
}
