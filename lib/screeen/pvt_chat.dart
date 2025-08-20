import 'package:chat_app/widget/pvt_msgs.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class PrivateChatScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String imageUrl;

  const PrivateChatScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.imageUrl,
  });

  @override
  State<PrivateChatScreen> createState() => _PrivateChatScreenState();
}

class _PrivateChatScreenState extends State<PrivateChatScreen> {
  //  Navigator.of(context).pop();
  //       final StorageRef = FirebaseStorage.instance
  //           .ref()
  //           .child('user_pfp')
  //           .child("${response.user!.uid}.jpg");

  //       await StorageRef.putFile(_pickedImage!);

  //       final uurl = await StorageRef.getDownloadURL();

  //       final user = FirebaseAuth.instance.currentUser!;

  //       await db.collection("users").doc(response.user!.uid).set({
  //         "user_id": user.uid,
  //         "email": _email,
  //         "username": _username,
  //         "image_url": uurl,
  //       });

  final authenticatedUser = FirebaseAuth.instance.currentUser!;
  TextEditingController messageController = TextEditingController();
  var downloadUrl;
  late PlatformFile file;
  bool _isFileLoading = false;

  Future<String> uploadFile(PlatformFile file) async {
    final storageRef =
        FirebaseStorage.instance.ref().child('chat_files/${file.name}');
    UploadTask uploadTask;
    if (file.bytes != null) {
      // For web: upload from bytes
      uploadTask = storageRef.putData(file.bytes!);
    } else {
      // For mobile/desktop: upload from file path
      uploadTask = storageRef.putFile(File(file.path!));
    }
    await uploadTask;
    final downloadUrl = await storageRef.getDownloadURL();
    return downloadUrl;
  }

  Future<void> pickFile() async {
    setState(() {
      _isFileLoading = true;
    });
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      file = result.files.first;
      String url = await uploadFile(file);
      if (!mounted) return; // Check if the widget is still mounted
      setState(() {
        downloadUrl = url;
        _isFileLoading = false;
      });
    } else {
      setState(() {
        _isFileLoading = false;
      });
    }
  }

  void pushMessage() async {
    if (messageController.text.trim().isEmpty && downloadUrl == null) {
      //make this snackbar dismissible

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Enter somehing to send."),
          duration: const Duration(seconds: 1),
        ),
      );
      return;
    }

    //  final StorageRef = FirebaseStorage.instance
    // .ref()
    // .child('user_pfp')
    // .child("${response.user!.uid}.jpg");

    final url = downloadUrl;
    final response =
        await FirebaseFirestore.instance.collection('private_chats').add({
      'message': url ?? messageController.text,
      'senderId': authenticatedUser.uid,
      'receiverId': widget.userId,
      'timestamp': Timestamp.now(),
    });

    print("Message sent: ${messageController.text}, Response: $response");
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(widget.imageUrl),
            ),
            SizedBox(width: 10),
            Text(widget.username),
          ],
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          PvtMsgs(
            receiverId: widget.userId,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                _isFileLoading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        icon: Icon(Icons.add),
                        onPressed: _isFileLoading ? null : pickFile,
                      ),
                downloadUrl == null
                    ? Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onSubmitted: (message) {
                            messageController.text = message.trim();
                          },
                        ),
                      )
                    : Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.insert_drive_file, color: Colors.blue),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                file.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.cancel, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  downloadUrl = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    pushMessage();
                    setState(() {
                      downloadUrl = null;
                    });
                    messageController.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
