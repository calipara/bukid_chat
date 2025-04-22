import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'otp_verification_screen.dart';
import 'privacy_policy_screen.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _verifyPhoneNumber() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    String phone = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');

    if (phone.startsWith('0')) {
      phone = phone.substring(1);
    }

    if (!phone.startsWith('+63')) {
      phone = '+63$phone';
    }

    setState(() => _isLoading = true);

    try {
      // Check if phone already exists
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        setState(() => _isLoading = false);
        _showAlreadyRegisteredDialog();
        return;
      }

      FirebaseAuth auth = FirebaseAuth.instance;

      await auth.verifyPhoneNumber(
        phoneNumber: phone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await auth.signInWithCredential(credential);
            await _saveUserData(auth.currentUser, name, phone);
            if (!mounted) return;
            Navigator.pushReplacementNamed(context, '/home');
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Auto sign-in failed: $e')),
              );
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hindi ma-verify: ${e.message}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() => _isLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpVerificationScreen(
                phoneNumber: phone,
                verificationId: verificationId,
                isSignUp: true,
                fullName: name,
              ),
            ),
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() => _isLoading = false);
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('May error habang sine-check ang number: $e')),
      );
    }
  }

  // ✅ Save user data to Firestore
  Future<void> _saveUserData(User? user, String name, String phone) async {
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.set({
      'name': name,
      'phone': phone,
      'photoUrl': '',
      'birthday': '',
      'gender': '',
      'region': '',
      'province': '',
      'city': '',
      'farmingDuration': '',
      'profileCompletedAt': FieldValue.serverTimestamp(),
    });
  }

  void _showAlreadyRegisteredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('May Account Ka Na!'),
        content: const Text('Mukhang nakarehistro ka na. Maaari kang mag-login gamit ang iyong cellphone number.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: const Text('Mag-login'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gumawa ng Account'),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/signup_logo.png',
                    height: 150,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Magrehistro sa Bukid Chat',
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Salamat sa Iyong Kasipagan!",
                    style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  TextFormField(
                    controller: _nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Buong Pangalan',
                      prefixIcon: const Icon(Icons.person),
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pakilagay ang iyong pangalan';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Cellphone Number',
                      hintText: '922 123 4567',
                      prefixIcon: const Icon(Icons.smartphone),
                      prefixText: '+63 ',
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Pakilagay ang numero ng telepono';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Verify Button
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: _verifyPhoneNumber,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text(
                            'I-verify ang Numero',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                  const SizedBox(height: 20),

                  // Privacy Policy
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen()),
                      );
                    },
                    child: Text(
                      "Sa pagpapatuloy, tinatanggap mo ang aming Terms at Privacy Policy.",
                      style: theme.textTheme.bodySmall?.copyWith(
                        decoration: TextDecoration.underline,
                        color: Colors.blueGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Project by MG Calipara - MIT Student, National University",
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    textAlign: TextAlign.center,
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
