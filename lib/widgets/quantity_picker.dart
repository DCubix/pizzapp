import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class QuantityPicker extends StatelessWidget {
  const QuantityPicker({ required this.quantity, this.onChange, this.onDelete, this.allowAdd = true, this.color = Colors.black, super.key});

  final int quantity;
  final Function(int quantity)? onChange;
  final Function()? onDelete;
  final Color color;

  final bool allowAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = TextStyle(fontSize: 18.0, color: color.withAlpha(200));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: color.withAlpha(100)),
      ),
      clipBehavior: Clip.antiAlias,
      width: 90.0,
      height: 30.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              if (quantity - 1 <= 0) {
                onDelete?.call();
              }
              onChange?.call(quantity - 1);
            },
            child: Container(
              width: 24.0,
              color: theme.primaryColor,
              child: Icon(quantity == 1 ? LucideIcons.trash2 : LucideIcons.minus, color: Colors.white, size: 16.0),
            ),
          ),
          Expanded(
            child: Center(child: Text('$quantity', style: textTheme)),
          ),
          InkWell(
            onTap: allowAdd ? () {
              onChange?.call(quantity + 1);
            } : null,
            child: Container(
              width: 24.0,
              color: allowAdd ? theme.primaryColor : Colors.grey[500],
              child: const Icon(LucideIcons.plus, color: Colors.white, size: 16.0),
            ),
          ),
        ],
      ),
    );
  }
}