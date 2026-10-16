import 'package:flutter/material.dart';

Color bestAnswerForeground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF8CCBFF)
    : const Color(0xFF1769AA);

Color bestAnswerBackground(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF17364B)
    : const Color(0xFFEAF4FC);
