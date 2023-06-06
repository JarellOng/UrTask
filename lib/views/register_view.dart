import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urtask/services/auth/auth_exceptions.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/bloc/auth_state.dart';
import 'package:urtask/utilities/dialogs/error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

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
      listener: (context, state) async {
        // Auth Exceptions
        if (state is AuthStateRegistering) {
          if (state.exception is WeakPasswordAuthException) {
            await showErrorDialog(
                context, "Password needs to be more than 5 characters!");
          } else if (state.exception is EmailAlreadyInUseAuthException) {
            await showErrorDialog(context, "Email is already in use!");
          } else if (state.exception is InvalidEmailAuthException) {
            await showErrorDialog(context, "Not a valid email!");
          } else if (state.exception is GenericAuthException) {
            await showErrorDialog(
              context,
              "Failed to register, please try again later..",
            );
          }
        }
      },
      child: Scaffold(
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
          // Added SingleChildScrollView
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                const Text(
                  "Register",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),

                // Name
                const SizedBox(height: 30),
                TextFormField(
                  controller: _name,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    hintText: "Name",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),

                // Email
                const SizedBox(height: 20),
                TextFormField(
                  controller: _email,
                  enableSuggestions: false,
                  autocorrect: false,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: "Email",
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                  ),
                ),

                // Password
                const SizedBox(height: 20),
                TextFormField(
                  controller: _password,
                  obscureText: _isHidden,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
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
                const SizedBox(height: 20),
                TextFormField(
                  controller: _repeatPassword,
                  obscureText: _isHidden2,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    hintText: 'Repeat Password',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 15.0,
                      horizontal: 20.0,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _toggleRepeatPasswordVisibility,
                      child: Icon(
                        _isHidden2 ? Icons.visibility : Icons.visibility_off,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 80),
                Center(
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton(
                        onPressed: () => _submit(),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color>(
                            const Color(0xFF9C3B35),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        child: const Text(
                          "Enter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 90),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Center(
                      child: Text(
                        "Need to verify?\n Try logging in with the registered email!",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit() async {
    if (_password.text != _repeatPassword.text) {
      await showErrorDialog(
          context, "Your repeat passsword does not match with your password");
    } else {
      _register();
    }
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
