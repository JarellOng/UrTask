import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _repeatPassword;
  bool _isHidden = true;
  bool _isHidden2 = true;

  @override
  void initState() {
    _name = TextEditingController();
    _email = TextEditingController();
    _password = TextEditingController();
    _repeatPassword = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _repeatPassword.dispose();
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
              const Text(""),

              // Name
              TextField(
                controller: _name,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
                keyboardType: TextInputType.name,
                decoration: const InputDecoration(
                  hintText: "Name",
                ),
              ),

              // Email
              TextField(
                controller: _email,
                enableSuggestions: false,
                autocorrect: false,
                autofocus: true,
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

              // Repeat Password
              TextFormField(
                controller: _repeatPassword,
                obscureText: _isHidden,
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  hintText: 'Repeat Password',
                  suffixIcon: GestureDetector(
                    onTap: _toggleRepeatPasswordVisibility,
                    child: Icon(
                      _isHidden2 ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),

              Center(
                child: Column(
                  children: [
                    // Enter Button
                    TextButton(
                      onPressed: () => _register(),
                      child: const Text("Enter"),
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

  // Toggle Password Visibility
  void _togglePasswordVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  // Toggle Repeat Password Visibility
  void _toggleRepeatPasswordVisibility() {
    setState(() {
      _isHidden2 = !_isHidden2;
    });
  }

  void _register() async {
    context.read<AuthBloc>().add(
          AuthEventRegister(
            _name.text,
            _email.text,
            _password.text,
            _repeatPassword.text,
          ),
        );
  }
}
