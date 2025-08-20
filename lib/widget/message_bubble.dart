import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

// A MessageBubble for showing a single chat message on the ChatScreen.
class MessageBubble extends StatefulWidget {
  // Create a message bubble which is meant to be the first in the sequence.
  const MessageBubble.first({
    super.key,
    required this.userImage,
    required this.username,
    required this.message,
    required this.isMe,
  }) : isFirstInSequence = true;

  // Create a amessage bubble that continues the sequence.
  const MessageBubble.next({
    super.key,
    required this.message,
    required this.isMe,
  })  : isFirstInSequence = false,
        userImage = null,
        username = null;

  // Whether or not this message bubble is the first in a sequence of messages
  // from the same user.
  // Modifies the message bubble slightly for these different cases - only
  // shows user image for the first message from the same user, and changes
  // the shape of the bubble for messages thereafter.
  final bool isFirstInSequence;

  // Image of the user to be displayed next to the bubble.
  // Not required if the message is not the first in a sequence.
  final String? userImage;

  // Username of the user.
  // Not required if the message is not the first in a sequence.
  final String? username;
  final String message;

  // Controls how the MessageBubble will be aligned.
  final bool isMe;

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble> {
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
    final theme = Theme.of(context);

    return Stack(
      children: [
        if (widget.userImage != null)
          Positioned(
            top: 15,
            // Align user image to the right, if the message is from me.
            right: widget.isMe ? 0 : null,
            child: CircleAvatar(
              backgroundImage: NetworkImage(
                widget.userImage!,
              ),
              backgroundColor: theme.colorScheme.primary.withAlpha(180),
              radius: 23,
            ),
          ),
        Container(
          // Add some margin to the edges of the messages, to allow space for the
          // user's image.
          margin: const EdgeInsets.symmetric(horizontal: 46),
          child: Row(
            // The side of the chat screen the message should show at.
            mainAxisAlignment:
                widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Expanded(
                // <-- Add this
                child: Column(
                  crossAxisAlignment: widget.isMe
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  children: [
                    // First messages in the sequence provide a visual buffer at
                    // the top.
                    if (widget.isFirstInSequence) const SizedBox(height: 18),
                    if (widget.username != null)
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 13,
                          right: 13,
                        ),
                        child: Text(
                          widget.username!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(221, 255, 255, 255),
                          ),
                        ),
                      ),

                    // The "speech" box surrounding the message.
                    Container(
                      decoration: BoxDecoration(
                        color: widget.isMe
                            ? Colors.grey[300]
                            : theme.colorScheme.secondary.withAlpha(200),
                        // Only show the message bubble's "speaking edge" if first in
                        // the chain.
                        // Whether the "speaking edge" is on the left or right depends
                        // on whether or not the message bubble is the current user.
                        borderRadius: BorderRadius.only(
                          topLeft: !widget.isMe && widget.isFirstInSequence
                              ? Radius.zero
                              : const Radius.circular(12),
                          topRight: widget.isMe && widget.isFirstInSequence
                              ? Radius.zero
                              : const Radius.circular(12),
                          bottomLeft: const Radius.circular(12),
                          bottomRight: const Radius.circular(12),
                        ),
                      ),
                      // Set some reasonable constraints on the width of the
                      // message bubble so it can adjust to the amount of text
                      // it should show.
                      // constraints: BoxConstraints(
                      //   // maxWidth: MediaQuery.of(context).size.width *
                      //   //     0.7, // Limit bubble width
                      // ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 14,
                      ),
                      // Margin around the bubble.
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 12,
                      ),
                      child: widget.message.toString().startsWith(
                              'https://firebasestorage.googleapis.com')
                          ? InkWell(
                              onTap: () async {
                                fileUrl = widget.message;
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
                                                  widget.message.toString())
                                              .split('/')
                                              .last
                                              .split('?')
                                              .first
                                              .split('%2F')
                                              .last,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
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
                          : Text(
                              widget.message,
                              // maxLines: 5,
                              style: TextStyle(
                                color: widget.isMe
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : const Color.fromARGB(255, 255, 255, 255),
                                fontSize: 16,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
