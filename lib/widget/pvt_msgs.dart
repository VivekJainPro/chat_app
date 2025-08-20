import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PvtMsgs extends StatefulWidget {
  const PvtMsgs({super.key, required this.receiverId});

  final String receiverId;
  @override
  State<PvtMsgs> createState() => _PvtMsgsState();
}

class _PvtMsgsState extends State<PvtMsgs> {
  bool _isFileLoading = false;
  String? _downloadingFileName;
  String? fileUrl;
  String? fileName;

  Future<void> downloadAndOpenFile(String url, String fileName) async {
    setState(() {
      _isFileLoading = true;
      _downloadingFileName = fileName; // Track which file is downloading
    });
    try {
      final dir = await getApplicationDocumentsDirectory();
      String savePath = '${dir.path}/$fileName';

      if (File(savePath).existsSync()) {
        print('File already exists at: $savePath');
        await OpenFilex.open(savePath);
        return;
      }

      Dio dio = Dio();
      await dio.download(
        url,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print(
                'Downloading: ${(received / total * 100).toStringAsFixed(0)}%');
          }
        },
      );

      print('File downloaded to: $savePath');
      await OpenFilex.open(savePath);
    } catch (e) {
      print('Error downloading or opening file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading or opening file: $e')),
      );
    } finally {
      setState(() {
        _isFileLoading = false;
        _downloadingFileName = null; // Reset after download
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;
    // final receiverId = widget.receiverId;

    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('private_chats')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (ctx, chatSnapShots) {
          if (chatSnapShots.connectionState == ConnectionState.waiting) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ],
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
                final chatMessage = loadedMessages[index].data();
                print("heres the chatMessage $chatMessage");
                print("heres the authenticatedUser ${authenticatedUser.uid}");
                print("heres the receiverId ${widget.receiverId}");

                if ((chatMessage['senderId'] == authenticatedUser.uid &&
                        chatMessage['receiverId'] == widget.receiverId) ||
                    (chatMessage['receiverId'] == authenticatedUser.uid &&
                        chatMessage['senderId'] == widget.receiverId)) {
                  final message = chatMessage['message'];
                  bool isMe = chatMessage['senderId'] == authenticatedUser.uid;

                  return Row(
                      mainAxisAlignment: isMe
                          ? MainAxisAlignment.end
                          : MainAxisAlignment.start,
                      children: [
                        Card(
                          //set theme according to the theme of the app
                          color: Theme.of(context).colorScheme.onPrimary,

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: !isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                              topRight: isMe
                                  ? Radius.zero
                                  : const Radius.circular(12),
                              bottomLeft: const Radius.circular(12),
                              bottomRight: const Radius.circular(12),
                            ),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),

                          child: chatMessage['message'].toString().startsWith(
                                  'https://firebasestorage.googleapis.com')
                              ? InkWell(
                                  onTap: () async {
                                    fileUrl = chatMessage['message'];
                                    String fileName = Uri.parse(fileUrl!)
                                        .pathSegments
                                        .last
                                        .split('?')
                                        .first;
                                    downloadAndOpenFile(fileUrl!, fileName);
                                  },
                                  child: Row(
                                    
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Text(
                                              Uri.decodeFull(
                                                      chatMessage['message']
                                                          .toString())
                                                  .split('/')
                                                  .last
                                                  .split('?')
                                                  .first
                                                  .split('%2F')
                                                  .last,
                                              style: TextStyle(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                    ,
                                              ),
                                            ),
                                            (_isFileLoading &&
                                                    _downloadingFileName ==
                                                        Uri.parse(fileUrl!)
                                                            .pathSegments
                                                            .last
                                                            .split('?')
                                                            .first)
                                                ? SizedBox(
                                                    width: 24,
                                                    height: 24,
                                                    child:
                                                        CircularProgressIndicator(
                                                            strokeWidth: 2),
                                                  )
                                                : Icon(Icons.insert_drive_file,
                                                    color: Colors.blue),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      message,
                                      maxLines: 5,
                                      softWrap: true,
                                      style: ThemeData(
                                        textTheme: TextTheme(
                                          bodyLarge: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimary,
                                          ),
                                        ),
                                      ).textTheme.bodyMedium,
                                    ),
                                  ),
                                ),
                          // subtitle: Text("You"),
                        ),
                      ]);
                }
                return const SizedBox.shrink();
              },
            ),
          );
        });
  }
}
