import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final AuthService authService = AuthService();

  bool isLoading = false;
  bool obscurePassword = true;
  bool isChecked = false;

  /// REGISTER
  register() async {
    if (!isChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please accept the requirements"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        firstNameController.text.isEmpty ||
        lastNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("All fields are required"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await authService.register(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration Successful'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    setState(() {
      isLoading = false;
    });
  }

  /// TEXTFIELD
  Widget buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 18),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(18),
      ),

      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : false,

        decoration: InputDecoration(
          hintText: hint,

          hintStyle: TextStyle(color: Colors.grey.shade500),

          prefixIcon: Icon(icon, color: Colors.grey),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 20),

          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),

                  onPressed: () {
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              /// TOP TITLE
              const SizedBox(height: 10),

              const Text(
                "REGISTER",
                style: TextStyle(
                  color: Color(0xFF4DD0E1),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 50),

              /// WELCOME
              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Welcome to Food Spot 👋",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              const Align(
                alignment: Alignment.centerLeft,

                child: Text(
                  "Create your account and discover delicious foods around you.",
                  style: TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),

              const SizedBox(height: 35),

              /// FIRST NAME
              buildTextField(
                controller: firstNameController,
                hint: "First Name",
                icon: Icons.person_outline,
              ),

              /// LAST NAME
              buildTextField(
                controller: lastNameController,
                hint: "Last Name",
                icon: Icons.person_outline,
              ),

              /// EMAIL
              buildTextField(
                controller: emailController,
                hint: "Email Address",
                icon: Icons.email_outlined,
              ),

              /// PASSWORD
              buildTextField(
                controller: passwordController,
                hint: "Password",
                icon: Icons.lock_outline,
                isPassword: true,
              ),

              const SizedBox(height: 5),

              /// CHECKBOX
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Checkbox(
                    value: isChecked,
                    activeColor: const Color(0xFF4DD0E1),

                    onChanged: (value) {
                      setState(() {
                        isChecked = value!;
                      });
                    },
                  ),

                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(top: 12),

                      child: Text(
                        "I agree to the Terms & Conditions and Privacy Policy.",
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// REGISTER BUTTON
              SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: isLoading ? null : register,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4DD0E1),
                    elevation: 0,

                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),

                  child: isLoading
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),

              /// LOGIN
              Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Colors.grey),
                  ),

                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },

                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF4DD0E1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
