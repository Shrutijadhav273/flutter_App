import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String? selectedGender;

  final DatabaseHelper dbHelper = DatabaseHelper();

  void registerUser() async {
    if (_formKey.currentState!.validate()) {
      try {
        await dbHelper.insertUser(
          nameController.text.trim(),
          emailController.text.trim(),
          passwordController.text.trim(),
          selectedGender!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Registration Successful"),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Email already registered! Please login."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 15,
              margin: const EdgeInsets.symmetric(horizontal: 25),
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                            labelText: "Full Name",
                            border: OutlineInputBorder()),
                        validator: (value) =>
                            value!.isEmpty ? "Enter your name" : null,
                      ),
                      const SizedBox(height: 15),

                      // Email
                      TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                            labelText: "Email",
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter your email";
                          }
                          if (!value.contains("@")) {
                            return "Enter valid email";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Password
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: "Password",
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Enter password";
                          }
                          if (value.length < 8) {
                            return "Password must be at least 8 characters";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Confirm Password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                            labelText: "Re-enter Password",
                            border: OutlineInputBorder()),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),

                      // Gender Dropdown
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: "Gender"),
                        value: selectedGender,
                        items: ["Male", "Female", "Other"]
                            .map((gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedGender = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? "Select gender" : null,
                      ),

                      const SizedBox(height: 20),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        onPressed: registerUser,
                        child: const Text("Sign Up"),
                      ),

                      const SizedBox(height: 15),

                      // 🔥 Already Registered Section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Already Registered? "),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const LoginScreen()),
                              );
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}