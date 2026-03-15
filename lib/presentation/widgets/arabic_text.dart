import 'package:flutter/material.dart';
import 'package:quran_app/config/design_tokens.dart';
import 'package:quran_app/config/theme.dart';

class ArabicText extends StatelessWidget {
  const ArabicText(
    this.text, {
    super.key,
    this.fontSize = ArabicSize.ayah,
    this.color,
    this.textAlign = TextAlign.right,
  });

  final String text;
  final double fontSize;
  final Color? color;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textDirection: TextDirection.rtl,
      textAlign: textAlign,
      style: TextStyle(
        fontFamily: 'Amiri',
        fontSize: fontSize,
        height: 2,
        color: color ?? context.palette.textPrimary,
      ),
    );
  }
}
