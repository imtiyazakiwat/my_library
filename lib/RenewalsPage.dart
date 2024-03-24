import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class RenewalsPage extends StatefulWidget {
  @override
  _RenewalsPageState createState() => _RenewalsPageState();
}

class _RenewalsPageState extends State<RenewalsPage> {
  final CollectionReference tables =
  FirebaseFirestore.instance.collection('tables');

  List<DocumentSnapshot> nearExpirationTables = [];

  @override
  void initState() {
    super.initState();
    _fetchNearExpirationTables();
  }

  Future<void> _fetchNearExpirationTables() async {
    DateTime currentDate = DateTime.now();
    QuerySnapshot tableSnapshot = await tables.get();

    setState(() {
      nearExpirationTables = tableSnapshot.docs.where((table) {
        Map<String, dynamic> data = table.data() as Map<String, dynamic>;
        if (data.containsKey('selectedDate') && data['selectedDate'] != null) {
          DateTime selectedDate =
          DateTime.parse(data['selectedDate'] as String);
          // Calculate the difference in days
          int differenceInDays =
              selectedDate.difference(currentDate).inDays;
          return differenceInDays >= 0 && differenceInDays <= 10;
        } else {
          return false;
        }
      }).toList();
    });
  }

  Future<void> _renewTable(String tableId) async {
    // Get the document reference for the table
    DocumentReference tableRef = tables.doc(tableId);

    // Get the current selected date
    DocumentSnapshot tableSnapshot = await tableRef.get();
    String? selectedDateString = tableSnapshot.exists ? tableSnapshot['selectedDate'] as String? : null;

    if(selectedDateString != null) {
      DateTime? selectedDate = DateTime.tryParse(selectedDateString);

      if(selectedDate != null) {
        DateTime newSelectedDate = DateTime(selectedDate.year, selectedDate.month + 1, selectedDate.day);
        await tableRef.update({'selectedDate': DateFormat('yyyy-MM-dd').format(newSelectedDate)});
        _fetchNearExpirationTables(); // Refresh the table list
      } else {
        print('Failed to parse selected date');
      }
    } else {
      print('Selected date is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Renewals'),
      ),
      body: _buildTableList(),
    );
  }

  Widget _buildTableList() {
    if (nearExpirationTables.isEmpty) {
      // If there are no pending renewals
      return Center(
        child: Text(
          'No pending renewals',
          style: TextStyle(fontSize: 18.0),
        ),
      );
    }

    return ListView.builder(
      itemCount: nearExpirationTables.length,
      itemBuilder: (context, index) {
        DocumentSnapshot table = nearExpirationTables[index];
        String name = table['name'] ?? 'N/A';
        String mobileNo = table['mobileNo'] ?? 'N/A';
        int tableNo = table['tableNo'];

        // Calculate accurate days remaining to expire
        DateTime currentDate = DateTime.now();
        DateTime selectedDate =
        DateTime.parse(table['selectedDate'] as String);
        int daysRemaining = selectedDate
            .difference(currentDate)
            .inDays +
            1; // Adding 1 to include the current day

        return ListTile(
          title: Text('Table $tableNo'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: $name'),
              Text('Mobile No: $mobileNo'),
              Text('Expires in $daysRemaining days'),
            ],
          ),
          trailing: ElevatedButton(
            onPressed: () async {
              await _renewTable(table.id);
              // Show a success message after successful renewal
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Table $tableNo renewed successfully!'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: Text('Renew'),
          ),
          tileColor: Colors.red, // Highlight the table in red
        );
      },
    );
  }
}
