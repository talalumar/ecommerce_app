import 'package:client/screens/resetPassword_screen.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String email;
  final String otpType;
  const VerifyOtpScreen({required this.email, required this.otpType});

  @override
  State<VerifyOtpScreen> createState() => _VerifyOtpScreenState();
}

class _VerifyOtpScreenState extends State<VerifyOtpScreen> {
  final _otpControllers = List.generate(6, (index) => TextEditingController());

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    String otp = _otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    // Map<String, dynamic> result;

    if (widget.otpType == "register") {
        final result = await AuthService.verifyRegisterOtpApi(
          email: widget.email,
          otp: otp,
        );
        if (result["success"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("OTP Verified Successfully")),
          );
          Navigator.pushReplacementNamed(context, '/login');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result["message"] ?? "Invalid OTP")),
          );
        }
    }

      if (widget.otpType == "forgotPassword") {
          final result = await AuthService.verifyForgotPasswordOtpApi(
            email: widget.email,
            otp: otp,
          );

          if (result["success"] == true) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("OTP Verified Successfully")),
            );
            Navigator.pushReplacement(
                context,
              MaterialPageRoute(
                builder: (context) => ResetPasswordScreen(
                  email: widget.email,
                ),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result["message"] ?? "Invalid OTP")),
            );
          }
    }
  }

  void _resendOtp() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Resending OTP...")),
    );

    Map<String, dynamic> result;

    if (widget.otpType == "register") {
      result = await AuthService.resendRegisterOtpApi(widget.email);
    } else if (widget.otpType == "forgotPassword") {
      result = await AuthService.requestForgotPasswordApi(widget.email);
    } else {
      return;
    }

    if (result["success"] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "OTP sent successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Failed to resend OTP")),
      );
    }
  }



  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final email = args?["email"] ?? "";

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Verifying for $email"),
              const SizedBox(height: 60),

              // Title
              const Text(
                "Verify OTP",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter the 6-digit code sent to your email.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 40),

              // OTP input fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    child: TextField(
                      controller: _otpControllers[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: InputDecoration(
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        }
                        if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Verify Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: Colors.blue.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _verifyOtp,
                  child: const Text(
                    "Verify",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Resend OTP
              TextButton(
                onPressed: () {
                  _resendOtp();
                },
                child: const Text("Resend OTP"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
