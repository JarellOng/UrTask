import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/utilities/dialogs/logout_dialog.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userId = AuthService.firebase().currentUser!.id;
    final userEmail = AuthService.firebase().currentUser!.email;
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
                  ))),
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
                  bool shouldLogout = await showLogoutDialog(context);
                  if (shouldLogout) {
                    await AuthService.logOut();
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
