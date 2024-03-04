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
                title: Text('Table ${booking['tableNumber']}'),
                subtitle: Text('${booking['name']} - ${booking['village']}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.check),
                      onPressed: () {
                        approveBooking(booking.id, booking['tableNumber']);
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

  void approveBooking(String bookingId, int tableNumber) async {
    try {
      // Update the booking status to approved
      await FirebaseFirestore.instance.collection('bookings').doc(bookingId).update({'isApproved': true});

      // Mark the table as booked in the 'tables' collection
      await FirebaseFirestore.instance.collection('tables').doc('table_$tableNumber').set({
        'tableNo': tableNumber,
        'isBooked': true,
        // Add additional fields if needed
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
