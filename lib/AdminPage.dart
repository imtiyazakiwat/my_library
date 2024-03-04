import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   runApp(MyApp());
// }

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Edit Tables Info',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Arial', // Change the font to a more iOS-like font
      ),
      home: AdminPage(),
      debugShowCheckedModeBanner: false, // Hide the debug banner
    );
  }
}

class AdminPage extends StatelessWidget {
  const AdminPage({Key? key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tables Info'),
      ),
      body: AddTablePage(),
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
    // Query for the table with the selected table number
    Query query = tables.where('tableNo', isEqualTo: selectedTable);

    // Check if the table already exists
    query.get().then((querySnapshot) {
      // If the table exists, update its details
      if (querySnapshot.docs.isNotEmpty) {
        querySnapshot.docs.forEach((doc) {
          doc.reference.update({
            'isBooked': isBooked,
            if (isBooked) 'name': name,
            if (isBooked) 'village': village,
            if (isBooked) 'mobileNo': mobileNo,
          }).then((_) {
            print('Table updated');
          }).catchError((error) {
            print('Failed to update table: $error');
          });
        });
      } else {
        // If the table does not exist, add it to the collection
        tables.add({
          'tableNo': selectedTable,
          'isBooked': isBooked,
          if (isBooked) 'name': name,
          if (isBooked) 'village': village,
          if (isBooked) 'mobileNo': mobileNo,
        }).then((_) {
          print('Table added');
        }).catchError((error) {
          print('Failed to add table: $error');
        });
      }
    }).catchError((error) {
      print('Error checking table existence: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
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
    );
  }
}
