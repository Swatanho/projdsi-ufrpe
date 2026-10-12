import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'services/auth_service.dart';
import 'features/home/presentation/screens/login_screen.dart';
import 'features/onboarding/presentation/screens/intro_flow_screen.dart';
import 'views/home_screen.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HeartHealth',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const _AppEntry(),
    );
  }
}

class _AppEntry extends StatefulWidget {
  const _AppEntry();

  @override
  State<_AppEntry> createState() => _AppEntryState();
}

class _AppEntryState extends State<_AppEntry> {
  bool _introCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (!_introCompleted) {
      return IntroFlowScreen(
        onCompleted: () => setState(() => _introCompleted = true),
      );
    }

    return StreamBuilder<bool>(
      stream: AuthService.instance.isAuthenticated,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == true) {
          return const HomeScreen();
        }

        return const LoginScreen();
      },
    );
  }
}
