import 'package:flutter/material.dart';

class SmallChip extends StatelessWidget {
  const SmallChip(this.text, { this.backgroundColor = Colors.grey, this.fontSize = 13.0, this.rightMargin = 0.0, this.icon, Key? key }) : super(key: key);

  final String text;
  final IconData? icon;
  final Color backgroundColor;
  final double fontSize;
  final double rightMargin;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 6.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5.0),
        color: backgroundColor
      ),
      margin: EdgeInsets.only(right: rightMargin),
      clipBehavior: Clip.antiAlias,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: fontSize + 2.0, color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white),
              const SizedBox(width: 4.0),
            ],
            Text(
              text,
              style: TextStyle(
                color: backgroundColor.computeLuminance() > 0.5 ? Colors.black : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize
              ),
            ),
          ],
        ),
      ),
    );
  }
}
