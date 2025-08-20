import 'package:chat_app/widget/message_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  @override
  Widget build(BuildContext context) {

    final authenticatedUser = FirebaseAuth.instance.currentUser!;

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
          final loadedMessages = chatSnapShots.data!.docs;
          return Expanded(
            
            child: ListView.builder(
              
              reverse: true,
              itemCount: loadedMessages.length,
              itemBuilder: (ctx, index) {
                final chatMessage = loadedMessages[index].data() ;
                final nextChatMessage = index + 1 < loadedMessages.length
                    ? loadedMessages[index + 1].data()
                    : null;
              
              final CurrentMesasgeUserID = chatMessage['userId'];

              final NextMesasgeUserID = nextChatMessage != null ? nextChatMessage['userId']:null ;

              bool isSame = CurrentMesasgeUserID == NextMesasgeUserID;

              if(isSame){
                return MessageBubble.next(
                  // isFirstInSequence: isFirstInSequence,
                  // userImage: chatMessage['userImage'],
                  // username: chatMessage['username'],
                  message: chatMessage['chat'],
                  isMe: authenticatedUser.uid == CurrentMesasgeUserID,
                );
              }else{
                return MessageBubble.first(
                  userImage: chatMessage['userImage'],
                  username: chatMessage['username'],
                  message: chatMessage['chat'],
                  isMe: authenticatedUser.uid == CurrentMesasgeUserID,
                );}
                
              },
            ),
          );
        });
  }
}
