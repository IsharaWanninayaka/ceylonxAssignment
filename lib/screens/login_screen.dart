import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'base_auth_screen.dart';
import '../utils/validators.dart';
import '../utils/auth_error_handler.dart';
import '../utils/responsive.dart';

class LoginScreen extends BaseAuthScreen {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends BaseAuthScreenState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(context.wp(5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                buildAuthHeader(
                  title: 'TaskFlow',
                  subtitle: 'Manage your tasks efficiently',
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      buildAuthTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: Validators.validateEmail,
                      ),
                      buildAuthTextField(
                        controller: _passwordController,
                        labelText: 'Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        showVisibilityToggle: true,
                        onVisibilityChanged: (value) {
                          setState(() => _obscurePassword = value);
                        },
                        validator: Validators.validatePassword,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: context.hp(1.5)),
                Align(
                  alignment: Alignment.centerRight,
                  child: buildTextButton(
                    text: 'Forgot Password?',
                    onPressed: _showForgotPasswordDialog,
                    textColor: Colors.blue,
                    fontSize: 3.5,
                  ),
                ),
                buildErrorMessage(),
                SizedBox(height: context.hp(2.5)),
                if (isLoading)
                  buildLoadingIndicator()
                else
                  ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.hp(2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.wp(2.5)),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(
                        fontSize: context.tp(4.5),
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(height: context.hp(3.5)),
                buildDividerWithText('Don\'t have an account?'),
                SizedBox(height: context.hp(2.5)),
                buildSecondaryButton(
                  text: 'Create Account',
                  onPressed: _navigateToRegister,
                  borderColor: Colors.blue,
                  textColor: Colors.blue,
                  borderRadius: 2.5,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _loginUser() async {
    if (formKey.currentState!.validate()) {
      setLoading(true);
      clearErrorMessage();

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signIn(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        final errorMessage = AuthErrorHandler.handleAuthError(e, isLogin: true);
        setErrorMessage(errorMessage);
      } finally {
        setLoading(false);
      }
    }
  }

  void _navigateToRegister() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),
    );
  }

  void _showForgotPasswordDialog() {
    // Implement forgot password functionality
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Forgot Password'),
        content:
            const Text('Password reset functionality not implimented yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
