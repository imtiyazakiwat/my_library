import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminApprovalPage extends StatefulWidget {
  @override
  _AdminApprovalPageState createState() => _AdminApprovalPageState();
}

class _AdminApprovalPageState extends State<AdminApprovalPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Booking Requests'),
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('bookings').where('isApproved', isEqualTo: false).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No pending requests.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var booking = snapshot.data!.docs[index];
              return ListTile(
                title: Text('Table ${booking['tableNo']}'),
                subtitle: Text('${booking['name']} - ${booking['village']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        approveBooking(booking.id, booking['tableNo'], booking['name'], booking['village'], booking['phoneNumber']);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.close),
                      onPressed: () {
                        declineBooking(booking.id);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  void approveBooking(String bookingId, int tableNo, String name, String village, String phoneNumber) async {
    try {
      // Update the booking status to approved
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'isApproved': true});

      // Create the document if it doesn't exist
      final tableDoc = FirebaseFirestore.instance.collection('tables').doc('table_$tableNo');
      final tableSnapshot = await tableDoc.get();

      if (!tableSnapshot.exists) {
        // Document doesn't exist, create it
        await tableDoc.set({
          'tableNo': tableNo,
          'isBooked': true,
          'name': name,
          'mobileNo': phoneNumber,
          'village': village,
        });
      } else {
        // Document exists, update it
        await tableDoc.update({
          'tableNo': tableNo,
          'isBooked': true,
          'name': name,
          'phoneNumber': phoneNumber,
          'village': village,
        });
      }

      // Add booking details to the 'approved_bookings' collection
      await FirebaseFirestore.instance.collection('approved_bookings').add({
        'tableNo': tableNo,
        'name': name,
        'village': village,
        'phoneNumber': phoneNumber,
        'isApproved': true,
        'approvalDate': DateTime.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking request approved and table marked as booked.'),
        ),
      );
    } catch (error) {
      print('Error approving booking: $error');
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to approve booking.'),
        ),
      );
    }
  }

  void declineBooking(String bookingId) async {
    try {
      // Delete the booking request
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking request declined.'),
        ),
      );
    } catch (error) {
      print('Error declining booking: $error');
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to decline booking.'),
        ),
      );
    }
  }
}
