import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'resetPassword_screen.dart';

class VerifyOtpScreen extends StatefulWidget {
  final String otpType;
  const VerifyOtpScreen({required this.otpType});

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
    final auth = context.read<AuthProvider>();
    String otp = _otpControllers.map((e) => e.text).join();

    if (otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a 6-digit OTP")),
      );
      return;
    }

    bool success = false;


    if (widget.otpType == "register") {
      success = await auth.verifyRegisterOtp(otp: otp);
      if (success) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else if (widget.otpType == "forgotPassword") {
      success = await auth.verifyForgotPasswordOtp(
        otp: otp,
      );
      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ResetPasswordScreen(),
          ),
        );
      }
    }

    if (!success && auth.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage!)),
      );
    }
  }




  void _resendOtp() async {
    final auth = context.read<AuthProvider>();
    bool success = false;

    if (widget.otpType == "register") {
      success = await auth.resendRegisterOtp();
    } else if (widget.otpType == "forgotPassword") {
      success = await auth.resendForgotPasswordOtp();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(success ? "OTP sent successfully" : auth.errorMessage ?? "Failed to resend OTP")),
    );
  }



  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    final email = args?["email"] ?? "";

    return Scaffold(
      backgroundColor: Colors.grey[100],
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
              Consumer<AuthProvider>(
                builder: (context, auth, _) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: auth.isLoading ? null : () => _verifyOtp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: auth.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Verify", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              // Resend OTP
              Consumer<AuthProvider>(
                builder: (context, auth, child) {
                  return TextButton(
                    onPressed: auth.isLoading ? null : () =>
                        _resendOtp(),
                    child: const Text("Resend OTP"),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}