import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/utilities/dialogs/logout_dialog.dart';

class ProfileView extends StatefulWidget {
  final String name;

  const ProfileView({Key? key, required this.name}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final userEmail = AuthService.firebase().currentUser!.email;
  late String name;

  @override
  void initState() {
    name = widget.name;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.name,
          style: const TextStyle(fontSize: 20, color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.account_circle, size: 32, color: Colors.white),
          onPressed: () => Navigator.pop(context),
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
              style: Theme.of(context).textTheme.headline6,
            ),
            const SizedBox(height: 16.0),
            Text(
              userEmail,
              style: Theme.of(context).textTheme.subtitle1,
            ),
            const Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: TextButton(
                  onPressed: _shouldLogout,
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Color(0xFF9C3B35)),
                    shape: MaterialStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shouldLogout() async {
    final shouldLogout = await showLogoutDialog(context);
    if (shouldLogout) {
      if (mounted) {
        Navigator.of(context).pop(shouldLogout);
      }
    }
  }
}
