import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/user_details/user_detail_controller.dart';
import 'package:urtask/utilities/dialogs/logout_dialog.dart';

class ProfileView extends StatefulWidget {
  final String name;

  const ProfileView({Key? key, required this.name}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final UserDetailController _userDetailService;
  final user = AuthService.firebase().currentUser!;
  late final TextEditingController name;
  late final FocusNode nameFocus;
  bool nameFlag = true;

  @override
  void initState() {
    _userDetailService = UserDetailController();
    name = TextEditingController(text: widget.name);
    nameFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    name.dispose();
    nameFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          "Profile",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        leading: const BackButton(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME
            const Text(
              'Name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 200,
                  child: TextField(
                    focusNode: nameFocus,
                    readOnly: nameFlag,
                    controller: name,
                    enableSuggestions: false,
                    autocorrect: false,
                    style: const TextStyle(fontSize: 18),
                    decoration: const InputDecoration(
                      hintText: "Name",
                      border: InputBorder.none,
                    ),
                  ),
                ),
                if (nameFlag == true) ...[
                  TextButton(
                    onPressed: () => _changeName(),
                    child: const Text(
                      "Change",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ] else ...[
                  TextButton(
                    onPressed: () => _saveName(),
                    child: const Text(
                      "Save",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16.0),

            // EMAIL
            const Text(
              'Email',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 5.0),
            Text(
              user.email,
              style: const TextStyle(fontSize: 18),
            ),
            const Spacer(),
            Center(
              child: FractionallySizedBox(
                widthFactor: 0.5,
                child: TextButton(
                  onPressed: () => _shouldLogout(),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        const Color(0xFF9C3B35)),
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
                      fontSize: 18,
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

  void _changeName() {
    setState(() {
      nameFlag = false;
      nameFocus.requestFocus();
    });
  }

  void _saveName() {
    setState(() {
      nameFocus.unfocus();
      nameFlag = true;
      _userDetailService.updateName(id: user.id, name: name.text);
    });
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
