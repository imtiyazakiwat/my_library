import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
      title: 'Firestore Demo',
      home: AddTablePage(),
    );
  }
}

class AddTablePage extends StatefulWidget {
  @override
  _AddTablePageState createState() => _AddTablePageState();
}

class _AddTablePageState extends State<AddTablePage> {
  final CollectionReference tables =
  FirebaseFirestore.instance.collection('tables');

  int selectedTable = 1;
  bool isBooked = false;
  String name = '';
  String village = '';
  String mobileNo = '';

  void _toggleIsBooked(bool value) {
    setState(() {
      isBooked = value;
    });
  }

  void _saveTable() {
    tables.add({
      'tableNo': selectedTable,
      'isBooked': isBooked,
      if (isBooked) 'name': name,
      if (isBooked) 'village': village,
      if (isBooked) 'mobileNo': mobileNo,
    }).then((value) {
      print('Table Added');
    }).catchError((error) {
      print('Failed to add table: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Table to Firestore'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Table Details:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Table No: '),
                DropdownButton<int>(
                  value: selectedTable,
                  onChanged: (value) {
                    setState(() {
                      selectedTable = value!;
                    });
                  },
                  items: List.generate(87, (index) => index + 1)
                      .map<DropdownMenuItem<int>>((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(value.toString()),
                    );
                  }).toList(),
                ),
              ],
            ),
            SizedBox(height: 20),
            SwitchListTile(
              title: Text('Is Booked?'),
              value: isBooked,
              onChanged: _toggleIsBooked,
            ),
            if (isBooked) ...[
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Village'),
                onChanged: (value) {
                  setState(() {
                    village = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Mobile No'),
                onChanged: (value) {
                  setState(() {
                    mobileNo = value;
                  });
                },
              ),
              SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _saveTable,
              child: Text('Save Table'),
            ),
          ],
        ),
      ),
    );
  }
}
