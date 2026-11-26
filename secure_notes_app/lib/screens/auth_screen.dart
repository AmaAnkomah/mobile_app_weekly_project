import 'package:flutter/material.dart';
import '../services/biometric_service.dart';
import '../services/secure_storage_service.dart';
import 'notes_list_screen.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}


class _AuthScreenState extends State<AuthScreen> {
  final BiometricService _biometricService = BiometricService();
  final TextEditingController _pinController = TextEditingController();
  bool _isBiometricSupported = false;


  @override
  void initState() {
    super.initState();
    _checkBiometrics();
  }


  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await _biometricService.canCheckBiometrics();
      if (mounted) setState(() => _isBiometricSupported = canCheck);
      if (canCheck) {
        _authenticateWithBiometrics();
      }
    } catch (e) {
      if (mounted) setState(() => _isBiometricSupported = false);
    }
  }


  Future<void> _authenticateWithBiometrics() async {
    try {
      final authenticated = await _biometricService.authenticate();
      if (authenticated) {
        if (!mounted) return;
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotesListScreen()));
      }
    } catch (e) {
      // Fail silently and allow PIN login
    }
  }


  Future<void> _verifyPin() async {
    final storedHash = await SecureStorageService.loadPinHash();
    if (storedHash == null) {
      _setupPin();
      return;
    }
    final inputHash = sha256.convert(utf8.encode(_pinController.text)).toString();
    if (inputHash == storedHash) {
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NotesListScreen()));
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Wrong PIN')));
    }
  }


  void _setupPin() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Set PIN'),
        content: TextField(
          controller: _pinController,
          obscureText: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Enter 4-6 digit PIN'),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (_pinController.text.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('PIN must be at least 4 digits')));
                return;
              }
              final hash = sha256.convert(utf8.encode(_pinController.text)).toString();
              await SecureStorageService.savePinHash(hash);
              if (!mounted) return;
              Navigator.pop(context);
              _verifyPin();
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade900, Colors.black],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, size: 80, color: Colors.white),
              const SizedBox(height: 20),
              const Text(
                'SECURE NOTES',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 50),
              if (_isBiometricSupported) ...[
                ElevatedButton.icon(
                  onPressed: _authenticateWithBiometrics,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Unlock with Biometrics'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 20),
                const Text('OR', style: TextStyle(color: Colors.white70)),
              ],
              const SizedBox(height: 20),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Enter PIN',
                  labelStyle: const TextStyle(color: Colors.white70),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.blueAccent),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _verifyPin,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.white10,
                ),
                child: const Text('Unlock with PIN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
