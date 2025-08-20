import 'package:chat_app/widget/chatBox.dart';
import 'package:chat_app/widget/chat_messages.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  

  void pushNotificationManager() async{
    final fcm = FirebaseMessaging.instance;
    fcm.requestPermission();
    // final token  = await fcm.getToken();
    
    // print("Push Notification Manager Initialized, token: $token");

    // fcm.subscribeToTopic("chat");

    // To be notified whenever the token is updated, subscribe to the onTokenRefresh stream:

  // FirebaseMessaging.instance.onTokenRefresh
  //   .listen((fcmToken) {
  //     // TODO: If necessary send token to application server.

  //     // Note: This callback is fired at each app startup and whenever a new
  //     // token is generated.
  //   })
  //   .onError((err) {
  //     // Error getting token.
  //   });

  }

  @override
  void initState() {
    
    super.initState();
    pushNotificationManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat Screen'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ), 
      body: Center(
        child: Column(children: const [
          ChatMessages(),
          ChatBox(),
        ],),
      ),
    );
  }
}
