import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionGate extends StatefulWidget {
  final VoidCallback onGranted;
  const PermissionGate({super.key, required this.onGranted});

  @override
  State<PermissionGate> createState() => _PermissionGateState();
}

class _PermissionGateState extends State<PermissionGate> {
  bool _requesting = false;
  String _status = 'App needs permission to continue';

  Future<void> _request() async {
    setState(() {
      _requesting = true;
      _status = 'Requesting permission...';
    });

    // Request the permissions you actually need.
    // For a soft-lock demo these are enough.
    final statuses = await [
      Permission.storage,
      Permission.phone,
      Permission.sms,
    ].request();

    final allGranted = statuses.values.every(
      (s) => s.isGranted || s.isLimited,
    );

    if (allGranted) {
      widget.onGranted();
    } else {
      setState(() {
        _requesting = false;
        _status = 'Permission denied. Grant them to continue.';
      });
      // Optional: open settings
      // openAppSettings();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.security, size: 72, color: Colors.amber),
              const SizedBox(height: 24),
              const Text(
                'Permission Required',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _status,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _requesting ? null : _request,
                  child: _requesting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Grant Permission'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
