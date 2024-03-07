import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firestore Database Setup',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: DatabaseSetupPage(),
    );
  }
}

class DatabaseSetupPage extends StatefulWidget {
  @override
  _DatabaseSetupPageState createState() => _DatabaseSetupPageState();
}

class _DatabaseSetupPageState extends State<DatabaseSetupPage> {
  final CollectionReference librariesCollection =
  FirebaseFirestore.instance.collection('libraries');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Setup'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            createDatabase();
          },
          child: Text('Create Database'),
        ),
      ),
    );
  }

  Future<void> createDatabase() async {
    try {
      await librariesCollection.doc('sharadha library').set({
        'name': 'Sharadha Library',
      });

      // Creating tables
      await librariesCollection
          .doc('sharadha library')
          .collection('tables')
          .doc('table_1')
          .set({
        'name': 'Table 1',
      });

      await librariesCollection
          .doc('sharadha library')
          .collection('tables')
          .doc('table_2')
          .set({
        'name': 'Table 2',
      });

      await librariesCollection
          .doc('sharadha library')
          .collection('tables')
          .doc('table_3')
          .set({
        'name': 'Table 3',
      });

      // Add more tables as needed

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Database created successfully!'),
        ),
      );
    } catch (e) {
      print('Error creating database: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating database'),
        ),
      );
    }
  }
}
