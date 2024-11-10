import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final double elevation;
  final bool isEnabled;
  final bool isRounded;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.backgroundColor = Colors.blueAccent,
    this.textColor = Colors.white,
    this.borderRadius = 12.0,
    this.elevation = 4.0,
    this.isEnabled = true,
    this.isRounded = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBackgroundColor =
        isEnabled && onPressed != null ? backgroundColor : Colors.grey[400]!;
    final double effectiveBorderRadius = isRounded ? borderRadius : 0;

    return Material(
      elevation: isEnabled && onPressed != null ? elevation : 0,
      borderRadius: BorderRadius.circular(effectiveBorderRadius),
      color: effectiveBackgroundColor,
      child: InkWell(
        onTap: isEnabled && onPressed != null ? onPressed : null,
        borderRadius: BorderRadius.circular(effectiveBorderRadius),
        splashColor: isEnabled && onPressed != null
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(effectiveBorderRadius),
          ),
          child: Text(
            label,
            style: TextStyle(
              color:
                  isEnabled && onPressed != null ? textColor : Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
