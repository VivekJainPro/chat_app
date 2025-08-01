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
  Map<String, dynamic>? selectedUser; // For selected chat user

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
      // Select first user (not self) by default for chat
      if (fetchedUsers.length > 1) {
        selectedUser = fetchedUsers.firstWhere(
          (u) => u['user_id'] != authenticatedUser.uid,
          orElse: () => fetchedUsers[0],
        );
      }
    });
  }

  void selectUser(Map<String, dynamic> user) {
    setState(() {
      selectedUser = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWeb = MediaQuery.of(context).size.width > 900;
    if (!isWeb) {
      // Fallback to old navigation for mobile
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
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView.builder(
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
                        if (user['user_id'] == authenticatedUser.uid) {
                          // Notes
                        } else {
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
                        }
                      },
                      child: Row(
                        mainAxisAlignment:
                            user['user_id'] == authenticatedUser.uid
                                ? MainAxisAlignment.center
                                : MainAxisAlignment.start,
                        children: [
                          if (user['user_id'] != authenticatedUser.uid)
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                user['image_url'] ??
                                    'https://via.placeholder.com/150',
                              ),
                              radius: 20,
                            ),
                          SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              user['user_id'] == authenticatedUser.uid
                                  ? 'Notes'
                                  : user['username'],
                              style: TextStyle(fontSize: 16),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      );
    }

    // Web layout: 3 columns
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.refresh),
          onPressed: fetchUsers,
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Row(
              children: [
                // Left: User List
                Container(
                  width: 250,
                  color: Colors.grey[100],
                  child: ListView.builder(
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      final isSelected =
                          selectedUser != null &&
                          selectedUser!['user_id'] == user['user_id'];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          selected: isSelected,
                          selectedTileColor: Colors.blue[50],
                          leading: user['user_id'] != authenticatedUser.uid
                              ? CircleAvatar(
                                  backgroundImage: NetworkImage(
                                    user['image_url'] ??
                                        'https://via.placeholder.com/150',
                                  ),
                                  radius: 20,
                                )
                              : Icon(Icons.note),
                          title: Text(
                            user['user_id'] == authenticatedUser.uid
                                ? 'Notes'
                                : user['username'],
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () => selectUser(user),
                        ),
                      );
                    },
                  ),
                ),
                VerticalDivider(width: 1),
                // Middle: Chat Area
                Expanded(
                  flex: 2,
                  child: selectedUser == null
                      ? Center(child: Text('Select a user to chat'))
                      : selectedUser!['user_id'] == authenticatedUser.uid
                          ? Center(
                              child: Text(
                                'Notes Section (for self)',
                                style: TextStyle(fontSize: 20),
                              ),
                            )
                          : PrivateChatScreen(
                              userId: selectedUser!['user_id'],
                              username: selectedUser!['username'],
                              imageUrl: selectedUser!['image_url'],
                              key: ValueKey(selectedUser!['user_id']),
                            ),
                ),
                VerticalDivider(width: 1),
                // Right: Every chatapp user & Notes
                Container(
                  width: 250,
                  color: Colors.grey[50],
                  child: Column(
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
                              MaterialPageRoute(
                                  builder: (context) => ChatScreen()),
                            );
                          },
                          child: Text('Every chatapp user'),
                        ),
                      ),
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListTile(
                          leading: Icon(Icons.note),
                          title: Text('Notes'),
                          onTap: () {
                            // Select self for notes
                            final self = users.firstWhere(
                                (u) => u['user_id'] == authenticatedUser.uid,
                                orElse: () => {});
                            if (self != null) selectUser(self);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}