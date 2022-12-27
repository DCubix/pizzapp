import 'package:flutter/material.dart';

class SelectableButton extends StatelessWidget {
  const SelectableButton({ this.icon, required this.text, required this.selected, this.onTap, this.underText, super.key });

  final IconData? icon;
  final String text;
  final String? underText;
  final bool selected;
  final Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreColor = selected ? theme.primaryColor : Colors.black45;
    final textWidget = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w400, color: foreColor)),
        if (underText != null) Text(underText!, style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: foreColor))
      ],
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: foreColor,
          width: selected ? 2.0 : 1.0,
        ),
        color: selected ? theme.primaryColor.withAlpha(20) : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        enableFeedback: true,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: icon != null ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: foreColor),
              const SizedBox(width: 7.0),
              textWidget,
            ],
          ) : textWidget,
        ),
      ),
    );
  }
}