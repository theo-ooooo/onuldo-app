import 'package:flutter/material.dart';

/// 앱 로고 아이콘 위젯
class AppLogoIcon extends StatelessWidget {
  final double size;

  const AppLogoIcon({
    super.key,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF18181B),
        borderRadius: BorderRadius.circular(size * 0.2),
      ),
      child: Center(
        child: Text(
          '오',
          style: TextStyle(
            fontSize: size * 0.56,
            fontWeight: FontWeight.w300,
            color: const Color(0xFFFAFAFA),
            height: 1,
          ),
        ),
      ),
    );
  }
}

/// 앱 로고 + 워드마크 조합 위젯
class AppLogoWithText extends StatelessWidget {
  final double iconSize;
  final double fontSize;
  final Color? textColor;

  const AppLogoWithText({
    super.key,
    this.iconSize = 40,
    this.fontSize = 20,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppLogoIcon(size: iconSize),
        SizedBox(width: iconSize * 0.3),
        Text(
          '오늘도',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w400,
            color: textColor ?? const Color(0xFF18181B),
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}
