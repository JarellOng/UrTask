import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/utilities/dialogs/logout_dialog.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final userId = AuthService.firebase().currentUser!.id;
  final userEmail = AuthService.firebase().currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          userId,
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.account_circle, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16.0),
            Text(
              'Email',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16.0),
            Text(
              userEmail,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    if (mounted) {
                      Navigator.of(context).pop(shouldLogout);
                    }
                  }
                },
                child: const Text('Logout'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
