import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_setup_screen.dart';
import '../home/home_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String verificationId;
  final bool isSignUp;
  final String? fullName;

  const OtpVerificationScreen({
    Key? key,
    required this.phoneNumber,
    required this.verificationId,
    this.isSignUp = false,
    this.fullName,
  }) : super(key: key);

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(6, (_) => TextEditingController());
  bool _isVerifying = false;
  bool _resendEnabled = false;
  int _secondsRemaining = 60;
  bool _isComplete = false;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_secondsRemaining == 0) {
        timer.cancel();
        if (mounted) setState(() => _resendEnabled = true);
      } else {
        if (mounted) setState(() => _secondsRemaining--);
      }
    });
  }

  Future<void> _verifyOtp() async {
    String otp = _otpControllers.map((controller) => controller.text.trim()).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pakilagay ang kompletong 6-digit OTP.')),
      );
      return;
    }

    if (!mounted) return;

    setState(() {
      _isVerifying = true;
    });

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: otp,
      );

      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCredential.user;

      if (!mounted) return;

      if (widget.isSignUp && user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': widget.fullName ?? '',
          'phone': widget.phoneNumber,
          'photoUrl': '',
          'profileCompletedAt': null,
        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ProfileSetupScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maling OTP: ${e.message}')),
      );
    }
  }

  void _onOtpChanged(int index, String value) {
    setState(() {
      _isComplete = _otpControllers.every((controller) => controller.text.isNotEmpty);
    });

    if (value.isNotEmpty && index < 5) {
      FocusScope.of(context).nextFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Pag-verify'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: size.width * 0.08,
                vertical: 24,
              ),
              child: Column(
                children: [
                  Text(
                    'Ilagay ang 6-digit OTP na ipinadala sa:',
                    style: theme.textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.phoneNumber,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // OTP Boxes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) {
                      return SizedBox(
                        width: 50,
                        height: 50,
                        child: TextFormField(
                          controller: _otpControllers[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _otpControllers[index].text.isNotEmpty ? Colors.white : Colors.black,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            filled: true,
                            fillColor: _otpControllers[index].text.isNotEmpty ? Colors.green : Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(50),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "_",
                            hintStyle: TextStyle(color: Colors.grey[400]),
                          ),
                          onChanged: (value) {
                            _onOtpChanged(index, value);
                          },
                        ),
                      );
                    }),
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isVerifying || !_isComplete ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _isVerifying
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('I-verify at Magpatuloy'),
                    ),
                  ),

                  const SizedBox(height: 24),

                  !_resendEnabled
                      ? Text(
                          'Magpadala ng OTP sa loob ng $_secondsRemaining segundo',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        )
                      : TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Darating na ang "Resend OTP" feature!')),
                            );
                          },
                          child: const Text('Magpadala ulit ng OTP', style: TextStyle(color: Colors.green)),
                        ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      if (widget.isSignUp) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const SignUpScreen()),
                        );
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      }
                    },
                    child: const Text(
                      'Palitan ang Cellphone Number',
                      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
