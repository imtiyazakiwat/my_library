import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Demo',
      home: AddDataPage(),
    );
  }
}

class AddDataPage extends StatelessWidget {
  final CollectionReference users = FirebaseFirestore.instance.collection('users');

  Future<void> addUser() {
    return users
        .add({
      'name': 'John Doe',
      'age': 30,
      'email': 'johndoe@example.com',
    })
        .then((value) => print("User Added"))
        .catchError((error) => print("Failed to add user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Data to Firestore'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: addUser,
          child: Text('Add User'),
        ),
      ),
    );
  }
}
