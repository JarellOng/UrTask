import 'package:flutter/material.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  // Text Editing Controller
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool _isHidden = true;

  // Init State
  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  // Toggle Password Visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
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
          title: const Text("Login"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Email
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: "Email",
                ),
              ),

              // Password
              TextFormField(
                controller: _password,
                obscureText: _isHidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Password',
                  suffixIcon: GestureDetector(
                    onTap: _togglePasswordVisibility,
                    child: Icon(
                      _isHidden ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              // Login Button
              TextButton(
                onPressed: () async {
                  final email = _email.text;
                  final password = _password.text;
                  context.read<AuthBloc>().add(
                        AuthEventLogIn(
                          email,
                          password,
                        ),
                      );
                },
                child: const Text("Enter"),
              ),

              // Register Page Nav
              TextButton(
                onPressed: () {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text("Don't have an account? Sign up here"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
