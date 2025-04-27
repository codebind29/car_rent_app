import 'package:car_rent/authetication/services/authentication.dart';
import 'package:car_rent/authetication/signup_screen.dart';
import 'package:car_rent/authetication/snackbar.dart';
import 'package:car_rent/presentation/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'Password Forgot/forgotpassword.dart';
import 'btn.dart';

class LogInScreen extends StatefulWidget {
  const LogInScreen({super.key});

  @override
  State<LogInScreen> createState() => _LogInScreenState();
}

class _LogInScreenState extends State<LogInScreen> {
  final TextEditingController emailTextEditingController = TextEditingController();
  final TextEditingController passwordTextEditingController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true; // For toggling password visibility

  @override
  void dispose() {
    super.dispose();
    emailTextEditingController.dispose();
    passwordTextEditingController.dispose();
  }

  // Email and password authentication
  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    String res = await AuthMethod().loginUser(
        email: emailTextEditingController.text, password: passwordTextEditingController.text);

    if (res == "success") {
      setState(() {
        isLoading = false;
      });
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => HomePage(),
        ),
      );
    } else {
      setState(() {
        isLoading = false;
      });
      showSnackBar(context, res);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 50.0, bottom: 30),
                child: Image.asset(
                  "assets/images/logo.png",  // Ensure the path is correct
                  height: 150,
                  width: 150,
                ),
              ),
              Text(
                "Welcome Back!",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // Email Field
                    TextField(
                      controller: emailTextEditingController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email, color: Colors.deepPurple),
                        labelText: "Email",
                        labelStyle: TextStyle(fontSize: 14, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 20),

                    // Password Field with toggle
                    TextField(
                      controller: passwordTextEditingController,
                      obscureText: _obscurePassword,  // Toggle visibility based on _obscurePassword
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.lock, color: Colors.deepPurple),
                        labelText: "Password",
                        labelStyle: TextStyle(fontSize: 14, color: Colors.deepPurple),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.deepPurple),
                        ),
                        filled: true,
                        fillColor: Colors.deepPurple.shade50,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                            color: Colors.deepPurple,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;  // Toggle password visibility
                            });
                          },
                        ),
                      ),
                      style: TextStyle(color: Colors.black, fontSize: 15),
                    ),
                    const SizedBox(height: 20),

                    // Forgot Password Link
                    const ForgotPassword(),
                    const SizedBox(height: 20),

                    // Login Button
                    MyButtons(onTap: loginUser, text: "Log In"),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // TextButton for navigation to Signup screen
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (c) => SignUpScreen()));
                },
                child: const Text(
                  "Don't have an Account? Register here",
                  style: TextStyle(color: Colors.deepPurple),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


