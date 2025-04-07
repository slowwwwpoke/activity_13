import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _showFeedbackDialog(BuildContext context) {
    final TextEditingController feedbackController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Suggestions & Feedback'),
          content: TextField(
            controller: feedbackController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'Enter your feedback here...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final feedback = feedbackController.text;
                Navigator.pop(context);
                if (feedback.isNotEmpty) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('feedbacks')
                        .add({
                      'feedback': feedback,
                      'timestamp': FieldValue.serverTimestamp(),
                      'userEmail':
                          FirebaseAuth.instance.currentUser?.email ?? 'anonymous',
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback submitted!')),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: $e')),
                    );
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: TextField(
            controller: passwordController,
            decoration: const InputDecoration(
              labelText: 'New Password (min 6 chars)',
              border: OutlineInputBorder(),
            ),
            obscureText: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final newPassword = passwordController.text.trim();
                if (newPassword.length < 6) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password too short')),
                  );
                  return;
                }
                try {
                  await _auth.currentUser?.updatePassword(newPassword);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password updated')),
                  );
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              },
              child: const Text('Change'),
            ),
          ],
        );
      },
    );
  }

  void _logout(BuildContext context) async {
    await _auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final email = _auth.currentUser?.email ?? 'Unknown';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          )
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Logged in as: $email', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showChangePasswordDialog(context),
              child: const Text('Change Password'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showFeedbackDialog(context),
              child: const Text('Suggestions & Feedback'),
            ),
          ]),
        ),
      ),
    );
  }
}
