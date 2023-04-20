import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urtask/services/auth/auth_exceptions.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/bloc/auth_state.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  // Text Editing Controller
  late final TextEditingController _email;
  late final TextEditingController _password;

  // Init State
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // Dispose
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {},
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Register"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Enter your email and password to see your notes!"),

              // Email
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Enter your email here",
                ),
              ),

              // Password
              TextField(
                controller: _password,
                obscureText: true,
                enableSuggestions: false,
                autocorrect: false,
                decoration: const InputDecoration(
                  hintText: "Enter your password here",
                ),
              ),

              Center(
                child: Column(
                  children: [
                    // Register Button
                    TextButton(
                      onPressed: () async {
                        final email = _email.text;
                        final password = _password.text;
                        context.read<AuthBloc>().add(
                              AuthEventRegister(
                                email,
                                password,
                              ),
                            );
                      },
                      child: const Text("Register"),
                    ),

                    // Login Page Nav
                    TextButton(
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthEventLogOut());
                      },
                      child: const Text("Already registered? Login here!"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
