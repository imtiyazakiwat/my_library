import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableBookingPage extends StatefulWidget {
  @override
  _TableBookingPageState createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  List<int> bookedTables = [];
  int selectedTable = -1;

  @override
  void initState() {
    super.initState();
    fetchBookedTables();
  }

  Future<void> fetchBookedTables() async {
    try {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection('tables').get();

      setState(() {
        bookedTables = querySnapshot.docs
            .where((doc) => (doc.data() as Map<String, dynamic>).containsKey('isBooked') &&
            doc['isBooked'] == true &&
            (doc.data() as Map<String, dynamic>).containsKey('tableNo'))
            .map((doc) => doc['tableNo'] as int)
            .toList();
      });
    } catch (error) {
      print('Error fetching booked tables: $error');
    }
  }

  Future<void> bookTable(int tableNo) async {
    // Show dialog to input user details
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        String name = '';
        String village = '';
        String phoneNumber = '';

        return AlertDialog(
          title: Text('Enter Your Details'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Name'),
                  onChanged: (value) {
                    name = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Village'),
                  onChanged: (value) {
                    village = value;
                  },
                ),
                TextFormField(
                  decoration: InputDecoration(labelText: 'Phone Number'),
                  onChanged: (value) {
                    phoneNumber = value;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                // Add booking details to database for admin approval
                await FirebaseFirestore.instance.collection('bookings').add({
                  'tableNo': tableNo,
                  'name': name,
                  'village': village,
                  'mobileNo': phoneNumber,
                  'isApproved': false, // Initially not approved
                });

                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Booking request sent for approval.'),
                  ),
                );
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Table Booking'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/home');
          },
        ),
      ),
      body: GridView.count(
        crossAxisCount: 3,
        children: List.generate(
          87,
              (index) => GestureDetector(
            onTap: () {
              setState(() {
                if (!bookedTables.contains(index + 1)) {
                  selectedTable = index + 1;
                  bookTable(selectedTable);
                }
              });
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: bookedTables.contains(index + 1)
                    ? Colors.grey
                    : selectedTable == index + 1
                    ? Colors.lightGreen.withOpacity(0.7)
                    : Colors.green.withOpacity(0.3),
              ),
              child: Center(
                child: Text(
                  'Table ${index + 1}',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: bookedTables.contains(index + 1)
                        ? Colors.white
                        : selectedTable == index + 1
                        ? Colors.white
                        : Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
