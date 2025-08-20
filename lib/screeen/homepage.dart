import 'package:chat_app/screeen/auth.dart';
import 'package:chat_app/screeen/chat.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/screeen/pvt_chat.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  List<Map<String, dynamic>> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  void fetchUsers() async {
    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    if (!mounted) return;
    final fetchedUsers = snapshot.docs.map((doc) => doc.data()).toList();

    // Move the authenticated user (self) to the top of the list
    final selfUserIndex =
        fetchedUsers.indexWhere((u) => u['user_id'] == authenticatedUser.uid);
    if (selfUserIndex != -1) {
      final selfUser = fetchedUsers.removeAt(selfUserIndex);
      fetchedUsers.insert(0, selfUser);
    }

    setState(() {
      users = fetchedUsers;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: () {
            fetchUsers();
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              // Navigator.of(context).pop();
              // Log out functionality
              FirebaseAuth.instance.signOut();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AuthScreen(),
                ),
              );
            },
          ),
        ],
        title: Text('Chat App Home'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
              child: Text('Every chatapp user'),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];

                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      minimumSize: Size(double.infinity, 50),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PrivateChatScreen(
                            userId: user['user_id'],
                            username: user['username'],
                            imageUrl: user['image_url'],
                          ),
                        ),
                      );
                      print('Selected user: ${user['username']}');
                    },
                    child: Row(
                      mainAxisAlignment:
                          user['user_id'] == authenticatedUser.uid
                              ? MainAxisAlignment.center
                              : MainAxisAlignment.start,
                      children: [
                        if(user['user_id'] != authenticatedUser.uid)
                        CircleAvatar(
                          backgroundImage: NetworkImage(user['image_url'] ??
                              'https://via.placeholder.com/150'),
                          radius: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          user['user_id'] == authenticatedUser.uid
                              ? 'Notes'
                              : user['username'],
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
