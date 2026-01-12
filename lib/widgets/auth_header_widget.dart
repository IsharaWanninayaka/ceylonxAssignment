import 'package:flutter/material.dart';
import '../utils/responsive.dart';

class AuthHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final double verticalSpacing;

  const AuthHeader({
    Key? key,
    required this.title,
    required this.subtitle,
    this.verticalSpacing = 5.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: context.hp(verticalSpacing)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle,
              size: context.tp(8),
              color: Colors.blue,
            ),
            SizedBox(width: context.wp(2.5)),
            Text(
              title,
              style: TextStyle(
                fontSize: context.tp(8),
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
        SizedBox(height: context.hp(1.2)),
        Text(
          subtitle,
          style: TextStyle(
            fontSize: context.tp(4),
            color: Colors.grey,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: context.hp(verticalSpacing)),
      ],
    );
  }
}
