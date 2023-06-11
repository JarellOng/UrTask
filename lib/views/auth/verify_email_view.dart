import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/utilities/dialogs/password_reset_email_sent_dialog.dart';

class VerifyEmailView extends StatefulWidget {
  const VerifyEmailView({Key? key}) : super(key: key);

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  final userEmail = AuthService.firebase().currentUser!.email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor:
            const Color(0xFFFCC8BD), // Same color as Scaffold background
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black, // Change the color to black
          ),
          onPressed: () {
            context.read<AuthBloc>().add(const AuthEventLogOut());
          },
        ),
      ),
      backgroundColor: const Color(0xFFFCC8BD),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Column(
                children: [
                  const SizedBox(height: 100),
                  Image.asset(
                    'assets/gmail.png', // Replace with the correct path of the image
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Verify your email address",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    "You’ve entered",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            Text(
              "${userEmail.substring(0, 1)}*****${userEmail.substring(userEmail.indexOf("@") - 2)}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const Center(
              child: Text(
                "as the email address to your account.\n\n Please verify your email address by clicking on the link in the email we’ve sent.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: TextButton(
                onPressed: () => _sendEmailVerification(),
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(const Color(0xFF9C3B35)),
                  shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                child: const Text(
                  "Resend",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmailVerification() async {
    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
    await showSuccessDialog(
      context,
      "We have sent you a verification email. Please check your email for more information.",
    );
  }
}
