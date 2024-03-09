import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';


class AdminTablePage extends StatefulWidget {
  @override
  _AdminTablePageState createState() => _AdminTablePageState();
}

class _AdminTablePageState extends State<AdminTablePage> {
  final CollectionReference tables =
  FirebaseFirestore.instance.collection('tables');

  int selectedTable = 1;
  bool isBooked = false;
  String name = '';
  String village = '';
  String mobileNo = '';
  DateTime? selectedDate;

  TextEditingController nameController = TextEditingController();
  TextEditingController villageController = TextEditingController();
  TextEditingController mobileNoController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchTableData(selectedTable);
  }

  @override
  void dispose() {
    nameController.dispose();
    villageController.dispose();
    mobileNoController.dispose();
    super.dispose();
  }

  void _fetchTableData(int tableNo) {
    tables.doc('table_$tableNo').get().then((doc) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>;
        setState(() {
          isBooked = data.containsKey('isBooked') ? data['isBooked'] : false;
          if (isBooked) {
            name = data.containsKey('name') ? data['name'] : '';
            village = data.containsKey('village') ? data['village'] : '';
            mobileNo = data.containsKey('mobileNo') ? data['mobileNo'] : '';
            nameController.text = name;
            villageController.text = village;
            mobileNoController.text = mobileNo;

            // Retrieve and parse selected date from Firestore
            if (data.containsKey('selectedDate')) {
              String? dateString = data['selectedDate'];
              selectedDate = dateString != null ? DateTime.parse(dateString) : null;
            } else {
              selectedDate = null;
            }
          } else {
            name = '';
            village = '';
            mobileNo = '';
            nameController.clear();
            villageController.clear();
            mobileNoController.clear();
            selectedDate = null; // Reset selectedDate if not booked
          }
        });
      } else {
        setState(() {
          isBooked = false;
          name = '';
          village = '';
          mobileNo = '';
          nameController.clear();
          villageController.clear();
          mobileNoController.clear();
          selectedDate = null; // Reset selectedDate if document does not exist
        });
      }
    }).catchError((error) {
      print('Error fetching table data: $error');
    });
  }

  void _toggleIsBooked(bool value) {
    setState(() {
      isBooked = value;
    });
  }

  void _saveTable() {
    setState(() {
      _isLoading = true; // Show loading indicator
    });

    tables.doc('table_$selectedTable').set({
      'tableNo': selectedTable,
      'isBooked': isBooked,
      'name': isBooked ? nameController.text : '',
      'village': isBooked ? villageController.text : '',
      'mobileNo': isBooked ? mobileNoController.text : '',
      'selectedDate': selectedDate != null ? selectedDate!.toIso8601String() : null,
    }).then((_) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      print('Table saved/updated successfully');
      _showSaveSuccessDialog(); // Show success dialog
    }).catchError((error) {
      setState(() {
        _isLoading = false; // Hide loading indicator
      });
      print('Failed to save/update table: $error');
    });
  }

  void _showSaveSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Success'),
          content: Text('Your data has been saved successfully.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Tables Info'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _goToHome,
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTable,
        label: Text('Save Table'),
        icon: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(), // Show loading indicator
      );
    } else {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Table No: '),
                DropdownButton<int>(
                  value: selectedTable,
                  onChanged: (value) {
                    setState(() {
                      selectedTable = value!;
                    });
                    _fetchTableData(selectedTable);
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
                controller: nameController,
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Village'),
                controller: villageController,
                onChanged: (value) {
                  setState(() {
                    village = value;
                  });
                },
              ),
              SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(labelText: 'Mobile No'),
                controller: mobileNoController,
                onChanged: (value) {
                  setState(() {
                    mobileNo = value;
                  });
                },
              ),
              SizedBox(height: 10),
    ElevatedButton(
    onPressed: () => _selectDate(context),
    child: Text(selectedDate != null
    ? 'Selected Date: ${DateFormat('d MMM yyyy').format(selectedDate!)}'
        : 'Select Date'),
    ),

              SizedBox(height: 20),
            ],
          ],
        ),
      );
    }
  }

  void _goToHome() {
    // Navigate back to home page
    Navigator.pushReplacementNamed(context, '/home');
  }
}
