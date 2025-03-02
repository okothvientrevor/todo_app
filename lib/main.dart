import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/todo_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TodoProvider()),
      ],
      child: MaterialApp(
        title: 'Todo App',
        theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
        home: LandingPage(),
      ),
    );
  }
}

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  bool _isLoading = false;
  String _statusMessage = "Welcome to Todo App";
  bool _checkStarted = false;

  void _checkAuth() async {
    if (_checkStarted) return;

    setState(() {
      _checkStarted = true;
      _isLoading = true;
      _statusMessage = "Checking authentication status...";
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print("Starting auth check");

      // Add a timeout to prevent hanging
      bool isAuthenticated = await authProvider.checkAuthStatus().timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          print("Auth check timed out");
          return false;
        },
      );

      print("Auth check complete. Authenticated: $isAuthenticated");

      setState(() {
        _isLoading = false;
        _statusMessage =
            isAuthenticated ? "Authentication successful" : "Not authenticated";
      });

      // Navigate after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder:
                (context) =>
                    isAuthenticated ? const HomeScreen() : const LoginScreen(),
          ),
        );
      });
    } catch (e) {
      print("Error during auth check: $e");
      setState(() {
        _isLoading = false;
        _statusMessage = "Error: $e";
      });

      // Navigate to login after error
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Start auth check after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuth();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.blue,
                ),
                const SizedBox(height: 24),
                const Text(
                  "Todo App",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 32),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text("Go to Login"),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
