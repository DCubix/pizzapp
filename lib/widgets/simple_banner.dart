import 'dart:math';

import 'package:flutter/material.dart';

class SimpleBanner extends StatelessWidget {
  const SimpleBanner({ required this.text, this.color = Colors.green, super.key});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    const discountStyle = TextStyle(color: Colors.white, fontWeight: FontWeight.bold);
    final lightColor = Color.alphaBlend(Colors.white38, color);
    return Transform.translate(
      offset: const Offset(60.0, 0),
      child: Transform.rotate(
        alignment: Alignment.topCenter,
        angle: pi / 4,
        child: Container(
          width: 120.0,
          height: 50.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [ color, lightColor, color ],
              stops: const [ 0.2, 0.5, 0.8 ],

            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 4.0,
                spreadRadius: 0.0,
                offset: Offset(0.0, 2.0),
                color: Colors.black45,
              )
            ]
          ),
          padding: const EdgeInsets.only(bottom: 6.0),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(text, style: discountStyle),
            ),
          ),
        ),
      ),
    );
  }
}