import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TableBookingPage extends StatefulWidget {
  @override
  _TableBookingPageState createState() => _TableBookingPageState();
}

class _TableBookingPageState extends State<TableBookingPage> {
  List<int> bookedTables = [];

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
            .where((doc) => doc['isBooked'] == true)
            .map((doc) => doc['tableNo'] as int)
            .toList();
      });
    } catch (error) {
      print('Error fetching booked tables: $error');
    }
  }

  Future<void> updateTableStatus(int tableNo, bool isBooked) async {
    try {
      await FirebaseFirestore.instance
          .collection('tables')
          .doc('table$tableNo')
          .update({'isBooked': isBooked});
    } catch (error) {
      print('Error updating table status: $error');
    }
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
              int tableNo = index + 1;
              bool isBooked = !bookedTables.contains(tableNo);
              updateTableStatus(tableNo, isBooked);
              fetchBookedTables(); // Refresh booked tables
            },
            child: Container(
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                color: bookedTables.contains(index + 1)
                    ? Colors.grey
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
