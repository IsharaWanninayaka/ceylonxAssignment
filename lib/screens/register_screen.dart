import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'base_auth_screen.dart';
import '../utils/validators.dart';
import '../utils/auth_error_handler.dart';
import '../utils/responsive.dart';

class RegisterScreen extends BaseAuthScreen {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends BaseAuthScreenState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

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
                  subtitle: 'Create your account',
                ),
                Form(
                  key: formKey,
                  child: Column(
                    children: [
                      buildAuthTextField(
                        controller: _emailController,
                        labelText: 'Email Address',
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
                      buildAuthTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirm Password',
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscureConfirmPassword,
                        showVisibilityToggle: true,
                        onVisibilityChanged: (value) {
                          setState(() => _obscureConfirmPassword = value);
                        },
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                          value,
                          _passwordController.text,
                        ),
                      ),
                    ],
                  ),
                ),
                buildErrorMessage(),
                SizedBox(height: context.hp(2.5)),
                if (isLoading)
                  buildLoadingIndicator()
                else
                  ElevatedButton(
                    onPressed: _registerUser,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: context.hp(2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(context.wp(2.5)),
                      ),
                      backgroundColor: Colors.blue,
                    ),
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: context.tp(4.5),
                        color: Colors.white,
                      ),
                    ),
                  ),
                SizedBox(height: context.hp(2.5)),
                buildTermsText(),
                SizedBox(height: context.hp(3.5)),
                buildDividerWithText('Already have an account?'),
                SizedBox(height: context.hp(2.5)),
                buildSecondaryButton(
                  text: 'Sign In Instead',
                  onPressed: _navigateToLogin,
                  borderColor: Colors.blue,
                  textColor: Colors.blue,
                  borderRadius: 2.5,
                ),
                SizedBox(height: context.hp(2.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _registerUser() async {
    if (formKey.currentState!.validate()) {
      setLoading(true);
      clearErrorMessage();

      try {
        final authService = Provider.of<AuthService>(context, listen: false);
        await authService.signUp(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        // Navigate to Home Screen on success
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } catch (e) {
        final errorMessage =
            AuthErrorHandler.handleAuthError(e, isLogin: false);
        setErrorMessage(errorMessage);
      } finally {
        setLoading(false);
      }
    }
  }

  void _navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
