import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AuthErrorMessage extends StatelessWidget {
  final String message;
  final VoidCallback? onClose;

  const AuthErrorMessage({
    Key? key,
    required this.message,
    this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: context.hp(1.8)),
      child: Container(
        padding: EdgeInsets.all(context.wp(3)),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(context.wp(2)),
          border: Border.all(color: Colors.red[200] ?? Colors.red),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: context.tp(4.5)),
            SizedBox(width: context.wp(2.5)),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: Colors.red[700],
                  fontSize: context.tp(3.5),
                ),
              ),
            ),
            if (onClose != null)
              IconButton(
                icon: Icon(Icons.close, size: context.tp(4)),
                onPressed: onClose,
                color: Colors.grey[600],
              ),
          ],
        ),
      ),
    );
  }
}
