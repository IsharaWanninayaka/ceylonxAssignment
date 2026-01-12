import 'package:flutter/material.dart';
import '../utils/responsive.dart';
import '../widgets/auth_header_widget.dart';
import '../widgets/auth_error_message_widget.dart';
import '../widgets/auth_text_field_widget.dart';

abstract class BaseAuthScreen extends StatefulWidget {
  const BaseAuthScreen({Key? key}) : super(key: key);
}

abstract class BaseAuthScreenState<T extends BaseAuthScreen> extends State<T> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _errorMessage = '';

  GlobalKey<FormState> get formKey => _formKey;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void setLoading(bool value) {
    setState(() => _isLoading = value);
  }

  void setErrorMessage(String value) {
    setState(() => _errorMessage = value);
  }

  void clearErrorMessage() {
    setState(() => _errorMessage = '');
  }

  Widget buildAuthHeader({
    required String title,
    required String subtitle,
  }) {
    return AuthHeader(title: title, subtitle: subtitle);
  }

  Widget buildAuthTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    bool showVisibilityToggle = false,
    ValueChanged<bool>? onVisibilityChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool filled = true,
    EdgeInsets? margin,
  }) {
    return Container(
      margin: margin ?? EdgeInsets.only(bottom: context.hp(2.5)),
      child: AuthTextField(
        controller: controller,
        labelText: labelText,
        prefixIcon: prefixIcon,
        obscureText: obscureText,
        showVisibilityToggle: showVisibilityToggle,
        onVisibilityChanged: onVisibilityChanged,
        validator: validator,
        keyboardType: keyboardType,
        filled: filled,
      ),
    );
  }

  Widget buildErrorMessage() {
    return _errorMessage.isNotEmpty
        ? AuthErrorMessage(message: _errorMessage)
        : SizedBox(height: context.hp(1.8));
  }

  Widget buildLoadingIndicator() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.hp(2)),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
    Color backgroundColor = Colors.blue,
    double borderRadius = 10,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: context.hp(2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.wp(borderRadius)),
        ),
        backgroundColor: backgroundColor,
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: context.tp(4.5)),
      ),
    );
  }

  Widget buildSecondaryButton({
    required String text,
    required VoidCallback onPressed,
    Color borderColor = Colors.blue,
    Color textColor = Colors.blue,
    double borderRadius = 10,
  }) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: context.hp(2)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(context.wp(borderRadius)),
        ),
        side: BorderSide(color: borderColor),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: context.tp(4.5), color: textColor),
      ),
    );
  }

  Widget buildTextButton({
    required String text,
    required VoidCallback onPressed,
    Color textColor = Colors.blue,
    double fontSize = 4.0,
  }) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontSize: context.tp(fontSize),
          color: textColor,
        ),
      ),
    );
  }

  Widget buildDividerWithText(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.hp(2.5)),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.wp(2.5)),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: context.tp(3.5),
              ),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }

  Widget buildTermsText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: context.wp(5)),
      child: Text(
        'By registering, you agree to our Terms of Service and Privacy Policy',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: context.tp(3),
          color: Colors.grey[600],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
