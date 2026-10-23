import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://pbbbtwugizkuupzjejtb.supabase.co',
    publishableKey: 'sb_publishable_dkbpAaNWFEWblT-9Lo1TtQ_ixefcVcF',
  );
  runApp(const HifzTrackerApp());
}

final supabase = Supabase.instance.client;

class HifzTrackerApp extends StatelessWidget {
  const HifzTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hifz Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF071F18), // Tamnozelena
        primaryColor: const Color(0xFFD4AF37), // Zlatna
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4AF37),
          secondary: Color(0xFFF3E5AB),
          surface: Color(0xFF0E3328),
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF0E3328),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: const Color(0xFFD4AF37).withOpacity(0.35), width: 1.2),
          ),
          elevation: 6,
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// Provjera da li je korisnik prijavljen
class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    supabase.auth.onAuthStateChange.listen((data) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    final session = supabase.auth.currentSession;
    if (session == null) {
      return const LoginScreen();
    }
    return const HomeScreen();
  }
}

// ---------------- LOGIN EKRAN ----------------
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;

  Future<void> _authenticate() async {
    setState(() => _isLoading = true);
    try {
      if (_isSignUp) {
        await supabase.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Račun uspješno kreiran! Dobrodošli.')),
        );
      } else {
        await supabase.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Greška: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.menu_book, size: 64, color: Color(0xFFD4AF37)),
                  const SizedBox(height: 16),
                  const Text(
                    'HIFZ TRACKER',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFFD4AF37)),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'E-mail adresa', prefixIcon: Icon(Icons.email)),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Šifra', prefixIcon: Icon(Icons.lock)),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: const Color(0xFF071F18),
                      ),
                      onPressed: _isLoading ? null : _authenticate,
                      child: Text(_isSignUp ? 'Registruj se' : 'Prijavi se'),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isSignUp = !_isSignUp),
                    child: Text(
                      _isSignUp ? 'Već imaš račun? Prijavi se' : 'Nemaš račun? Registruj se',
                      style: const TextStyle(color: Color(0xFFF3E5AB)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- POČETNA STRANICA ----------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hifz Tracker - Početna', style: TextStyle(color: Color(0xFFD4AF37))),
        backgroundColor: const Color(0xFF0E3328),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Color(0xFFD4AF37)),
            onPressed: () => supabase.auth.signOut(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Esselamu alejkum,', style: TextStyle(color: Colors.white70, fontSize: 16)),
            Text(user?.email ?? 'Korisnik', style: const TextStyle(color: Color(0xFFD4AF37), fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildDashboardCard(context, 'Učenje novih stranica', Icons.book, () {
                    // Navigacija ka učenju
                  }),
                  _buildDashboardCard(context, 'Ponavljanje naučenog', Icons.repeat, () {}),
                  _buildDashboardCard(context, 'Zadnjih 10 stranica', Icons.history, () {}),
                  _buildDashboardCard(context, 'Slabe stranice (Semafor)', Icons.warning, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: const Color(0xFFD4AF37)),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
