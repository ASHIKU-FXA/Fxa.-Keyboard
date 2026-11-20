import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'lock_screen.dart';
import 'permission_gate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
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
  bool _loading = true;
  bool _locked = true;
  bool _permissionDone = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final locked = prefs.getBool('is_locked') ?? true;
    final perm = prefs.getBool('permission_done') ?? false;
    setState(() {
      _locked = locked;
      _permissionDone = perm;
      _loading = false;
    });
  }

  Future<void> _onPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('permission_done', true);
    setState(() => _permissionDone = true);
  }

  Future<void> _onUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_locked', false);
    setState(() => _locked = false);
  }

  Future<void> _relock() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_locked', true);
    setState(() => _locked = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!_permissionDone) {
      return PermissionGate(onGranted: _onPermissionGranted);
    }

    if (_locked) {
      return LockScreen(onUnlocked: _onUnlocked);
    }

    // Normal app after unlock
    return HomePage(onRelock: _relock);
  }
}

class HomePage extends StatefulWidget {
  final VoidCallback onRelock;
  const HomePage({super.key, required this.onRelock});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;

  void _increment() => setState(() => _counter++);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Flutter Demo Home Page'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock),
            onPressed: widget.onRelock,
            tooltip: 'Lock again',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
