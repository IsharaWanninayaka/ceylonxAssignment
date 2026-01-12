import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AuthTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final IconData prefixIcon;
  final bool obscureText;
  final bool showVisibilityToggle;
  final ValueChanged<bool>? onVisibilityChanged;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool filled;
  final bool enabled;
  final String? hintText;
  final int? maxLines;

  const AuthTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.prefixIcon,
    this.obscureText = false,
    this.showVisibilityToggle = false,
    this.onVisibilityChanged,
    this.validator,
    this.keyboardType,
    this.filled = true,
    this.enabled = true,
    this.hintText,
    this.maxLines = 1,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      style: TextStyle(fontSize: context.tp(4)),
      keyboardType: keyboardType,
      enabled: enabled,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(fontSize: context.tp(4)),
        hintText: hintText,
        hintStyle: TextStyle(fontSize: context.tp(3.5)),
        prefixIcon: Icon(prefixIcon, size: context.tp(5)),
        suffixIcon: showVisibilityToggle && onVisibilityChanged != null
            ? IconButton(
                icon: Icon(
                  obscureText ? Icons.visibility_off : Icons.visibility,
                  size: context.tp(5),
                  color: Colors.grey[600],
                ),
                onPressed: () => onVisibilityChanged!(!obscureText),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.wp(2.5)),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.wp(2.5)),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.wp(2.5)),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(context.wp(2.5)),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: filled,
        fillColor: filled ? Colors.grey[50] : null,
        contentPadding: EdgeInsets.symmetric(
          horizontal: context.wp(4),
          vertical: context.hp(2),
        ),
      ),
      validator: validator,
    );
  }
}
