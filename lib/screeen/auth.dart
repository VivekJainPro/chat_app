import 'dart:io';
import 'package:chat_app/widget/user_image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

final db = FirebaseFirestore.instance;
final _firebaseAuth = FirebaseAuth.instance;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  var _isloading = false;
  var _isLogin = true;
  var _password = "";
  var _email = "";
  var _username = "";
  File? _pickedImage;

  void _onSubmit() async {
    _form.currentState!.save();
    final isValid = _form.currentState!.validate();

    if (!isValid || (_pickedImage == null && !_isLogin)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all the fields correctly."),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _isloading = true;
    });

    try {
      if (_isLogin) {
        final response = await _firebaseAuth.signInWithEmailAndPassword(
            email: _email, password: _password);
        print("heres the login responses $response ");
        Navigator.of(context).pop();
      } else {
        final response = await _firebaseAuth.createUserWithEmailAndPassword(
            email: _email, password: _password);
        //use firebase firestore security rules to allow only authenticated users to write to the database or to make it more secure alllow only the user to write to their own document
        Navigator.of(context).pop();
        final StorageRef = FirebaseStorage.instance
            .ref()
            .child('user_pfp')
            .child("${response.user!.uid}.jpg");

        await StorageRef.putFile(_pickedImage!);

        final uurl = await StorageRef.getDownloadURL();
      
        final user = FirebaseAuth.instance.currentUser!;
        
        await db.collection("users").doc(response.user!.uid).set({
          "user_id": user.uid,
          "email": _email,
          "username": _username,
          "image_url": uurl,
        });

        // final user = <String, dynamic>{
        //   "email": _email,
        //   "username": _email.split('@')[0],
        //   "image_url": uurl,
        //   "user_id": response.user!.uid,
        // };

        // db.collection("users").add(user).then((DocumentReference doc) =>
        //     print('DocumentSnapshot added with ID: ${doc.id}'));
            
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message.toString()),
          duration: const Duration(seconds: 2),
          dismissDirection: DismissDirection.horizontal,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isloading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
                width: 200,
                // height: 200,
                child: Image.asset('assets/images/messaging.png'),
              ),
              Card(
                // padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Form(
                    key: _form,
                    child: Column(
                      children: [
                        if (!_isLogin)
                          UserImagePicker(
                            imagePicked: (imageFile) {
                              _pickedImage = imageFile;
                            },
                          ),
                        // const SizedBox(),
                        // if (!_isLogin && _pickedImage == null)
                        //   SnackBar(
                        //     content: Text("Please pick an image."),
                        //     duration: Duration(seconds: 1),
                        //   ),

                        Text(
                          _isLogin ? 'Login' : 'Sign Up',
                          style: TextStyle(
                            fontSize: 24,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                            labelText: 'Email',
                          ),
                          // autocorrect: false,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || !value.trim().contains('@')) {
                              return "Please enter valid email.";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _email = newValue!;
                          },
                        ),
                        if (!_isLogin)
                          TextFormField(
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.primary),
                            decoration: InputDecoration(
                              labelText: 'Username',
                            ),
                            
                            validator: (value) {
                              if (value == null || value.length < 4) {
                                return "UserName must contain atleat 4 characters.";
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _username = newValue!;
                            },
                          ),
                        TextFormField(
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.primary),
                          decoration: InputDecoration(
                            labelText: 'Password',
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return "Password must contain atleat 6 characters.";
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _password = newValue!;
                          },
                        ),
                        
                        const SizedBox(height: 12),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            foregroundColor:
                                Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withAlpha(220),
                          ),
                          onPressed: _onSubmit,
                          child: _isloading
                              ? CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                )
                              : Text(_isLogin ? 'Sign in' : 'Sign up'),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isLogin = !_isLogin;
                            });
                          },
                          child: Text(_isLogin
                              ? 'Create an account'
                              : 'I already have an account'),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
