import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String variant;
  final String size;
  final VoidCallback? onClick;

  const Logo({
    super.key,
    this.variant = 'light',
    this.size = 'md',
    this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = variant == 'light';
    final color = isLight ? Colors.white : Colors.black;

    double height;
    double fontSize;
    double iconSize;

    switch (size) {
      case 'sm':
        height = 32;
        fontSize = 18;
        iconSize = 24;
        break;
      case 'lg':
        height = 64;
        fontSize = 36;
        iconSize = 48;
        break;
      default:
        height = 48;
        fontSize = 24;
        iconSize = 32;
    }

    Widget content = SizedBox(
      height: height,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          CustomPaint(
            size: Size(iconSize, iconSize),
            painter: LogoPainter(color: color),
          ),
          const SizedBox(width: 8),
          
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: fontSize,
                color: color,
                letterSpacing: -0.5,
              ),
              children: const [
                TextSpan(
                  text: 'Luce',
                  style: TextStyle(fontWeight: FontWeight.w300),
                ),
                TextSpan(
                  text: 'Bella',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onClick != null) {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onClick,
          behavior: HitTestBehavior.opaque,
          child: content,
        ),
      );
    }

    return content;
  }
}

class LogoPainter extends CustomPainter {
  final Color color;

  LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    
    final path = Path()
      ..moveTo(size.width * 0.3, size.height * 0.2)
      ..lineTo(size.width * 0.3, size.height * 0.8)
      ..lineTo(size.width * 0.7, size.height * 0.8)
      ..lineTo(size.width * 0.7, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.7)
      ..lineTo(size.width * 0.4, size.height * 0.2)
      ..close();

    canvas.drawPath(path, paint);

    
    final sparklePaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(size.width * 0.6, size.height * 0.3), 2, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.75, size.height * 0.25), 1.5, sparklePaint);
    canvas.drawCircle(Offset(size.width * 0.65, size.height * 0.4), 1, sparklePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}