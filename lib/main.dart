import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:urtask/helpers/loading/loading_screen.dart';
import 'package:urtask/services/auth/bloc/auth_bloc.dart';
import 'package:urtask/services/auth/bloc/auth_event.dart';
import 'package:urtask/services/auth/bloc/auth_state.dart';
import 'package:urtask/services/auth/firebase_auth_provider.dart';
import 'package:urtask/utilities/navigation_service.dart';
import 'package:urtask/views/auth/login_view.dart';
import 'package:urtask/views/auth/register_view.dart';
import 'package:urtask/views/auth/verify_email_view.dart';
import 'package:urtask/views/home/home_view.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  var detroit = tz.getLocation('Asia/Jakarta');
  tz.setLocalLocation(detroit);
  await LocalNotificationCustom.initializeLocalNotifications();

  runApp(
    MaterialApp(
      title: 'UrTask',
      theme: ThemeData(
        primarySwatch: primary,
      ),
      home: BlocProvider<AuthBloc>(
        create: (context) => AuthBloc(FirebaseAuthProvider()),
        child: const HomePage(),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AuthBloc>().add(const AuthEventInitialize());
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isLoading) {
          LoadingScreen().show(
            context: context,
            text: state.loadingText ?? "Please wait a moment",
          );
        } else {
          LoadingScreen().hide();
        }
      },
      builder: (context, state) {
        if (state is AuthStateLoggedIn) {
          return const HomeView();
        } else if (state is AuthStateNeedsVerification) {
          return const VerifyEmailView();
        } else if (state is AuthStateLoggedOut) {
          return const LoginView();
        } else if (state is AuthStateRegistering) {
          return const RegisterView();
        } else {
          return Column();
        }
      },
    );
  }
}
