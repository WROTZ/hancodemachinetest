
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class PhoneOtpScreen extends StatefulWidget {
  const PhoneOtpScreen({super.key});

  @override
  State<PhoneOtpScreen> createState() => _PhoneOtpScreenState();
}

class _PhoneOtpScreenState extends State<PhoneOtpScreen> {
  final phoneController = TextEditingController();
  final otpController = TextEditingController();

  String? verificationId;
  bool isOtpSent = false;
  bool loading = false;

  Future<void> sendOtp() async {
    if (phoneController.text.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 10-digit phone number.")),
      );
      return;
    }
    setState(() => loading = true);
    
    // Enhanced Error Handling
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: "+91${phoneController.text}",
      verificationCompleted: (PhoneAuthCredential credential) async {
        debugPrint("Verification Completed Automatically");
        await FirebaseAuth.instance.signInWithCredential(credential);
        if (mounted) context.go('/');
      },
      verificationFailed: (FirebaseAuthException e) {
        debugPrint("Phone verification failed. Code: ${e.code}. Message: ${e.message}");
        setState(() => loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Verification Failed: ${e.message}")),
        );
      },
      codeSent: (String vId, int? resendToken) {
        debugPrint("OTP Code Sent. Verification ID: $vId");
        setState(() {
          verificationId = vId;
          isOtpSent = true;
          loading = false;
        });
      },
      codeAutoRetrievalTimeout: (String vId) {
        debugPrint("Auto-retrieval timeout for verification ID: $vId");
      },
      timeout: const Duration(seconds: 60),
    );
  }

  Future<void> verifyOtp() async {
    if (verificationId == null || otpController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the OTP.")),
      );
      return;
    }
    setState(() => loading = true);

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: otpController.text,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) context.go('/');
    } on FirebaseAuthException catch (e) {
      debugPrint("OTP verification failed. Code: ${e.code}. Message: ${e.message}");
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Invalid OTP: ${e.message}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UI remains the same...
    return Scaffold(
      appBar: AppBar(title: const Text("Phone Login")),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                readOnly: isOtpSent,
                decoration: const InputDecoration(
                  labelText: "Phone Number",
                  prefixText: "+91 ",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              if (isOtpSent)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                     Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Text(
                        "An OTP has been sent to +91 ${phoneController.text}",
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: "Enter OTP",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: loading ? null : (isOtpSent ? verifyOtp : sendOtp),
                child: Text(
                  loading
                      ? "Please wait..."
                      : isOtpSent
                          ? "Verify OTP"
                          : "Send OTP",
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
