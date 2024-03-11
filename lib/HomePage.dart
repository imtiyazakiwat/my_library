import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'AdminApprovalPage.dart'; // Import the AdminApprovalPage
import 'RenewalsPage.dart'; // Import the RenewalsPage

class HomePage extends StatelessWidget {
  final String userEmail;

  const HomePage({Key? key, required this.userEmail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sharada Library'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              _logout(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20.0),
                  Image.asset(
                    'assets/sharadhaLibImage.jpg',
                    height: 150.0,
                  ),
                  SizedBox(height: 20.0),
                  Text(
                    'Welcome to Sharada Library',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Text(
                      'Discover Your Perfect Study Haven: Tables Ready for Your Books and Ideas at Sharadha Library.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  SizedBox(height: 30.0),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/booking');
                    },
                    child: Text(
                      'Book a Table',
                      style: TextStyle(fontSize: 18.0),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 40.0, vertical: 15.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  // Conditional rendering for admin
                  if (_isAdmin(userEmail))
                    Column(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacementNamed(context, '/admin');
                          },
                          child: Text(
                            'View/Update Table Info',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => AdminApprovalPage()),
                            );
                          },
                          child: Text(
                            'Approve/Decline Requests',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                        SizedBox(height: 20.0),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RenewalsPage()),
                            );
                          },
                          child: Text(
                            'Renewals',
                            style: TextStyle(fontSize: 18.0),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to handle logout
  void _logout(BuildContext context) async {
    try {
      // Sign out the user from Firebase Authentication
      await FirebaseAuth.instance.signOut();

      // Close the current screen and return to the login screen
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } catch (e) {
      print("Error logging out: $e");
      // Handle any errors that occur during logout
    }
  }

  // Function to check if the user is an admin
  bool _isAdmin(String email) {
    // Check if the email matches the admin email
    if (email == 'libraryadmin@gmail.com') {
      return true;
    }

    // Check if the current user is signed in with Firebase
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null &&
        (currentUser.email == 'libraryadmin@gmail.com' || currentUser.email == 'ghorpadesudheer@gmail.com')) {
      return true;
    }

    return false;
  }
}
