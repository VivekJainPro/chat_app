import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key, required this.imagePicked});

  final void Function(File imageFile)
      imagePicked; // Function to handle image picking

  @override
  State<UserImagePicker> createState() => _UserImagePickerState();
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? _pickedImage; // Variable to store the picked image

  void _ImagePicker() async {
    ImagePicker imagePicker = ImagePicker();

    final pickResult = await imagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50, maxWidth: 150);

    if (pickResult == null) {
      return;
    }
    setState(() {
      _pickedImage = File(pickResult.path);
    });
    widget.imagePicked(
        _pickedImage!); // Call the function to pass the picked image
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          backgroundImage: _pickedImage != null
              ? FileImage(_pickedImage!)
              : AssetImage('assets/images/pfp.png'), // Replace with your image URL
        ),
        TextButton.icon(
          icon: Icon(Icons.image),
          label: Text(
            'Pick Image',
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          onPressed: () {
            _ImagePicker();
          },
        ),
      ],
    );
  }
}
