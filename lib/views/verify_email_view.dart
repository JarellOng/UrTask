import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/auth_service.dart';

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
          icon: Icon(
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
                  const SizedBox(height: 12),
                  const Text(
                    "You’ve entered",
                  ),
                ],
              ),
            ),
            Text(
              userEmail,
            ),
            Center(
              child: const Text(
                "as the email address to your account. Please verify your email address by clicking on the link in the email we’ve sent.",
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 20),
            FractionallySizedBox(
              widthFactor: 0.5,
              child: TextButton(
                onPressed: () => _sendEmailVerification(),
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
                  "Resend",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendEmailVerification() {
    context.read<AuthBloc>().add(const AuthEventSendEmailVerification());
  }
}
