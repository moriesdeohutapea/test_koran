import 'package:flutter/material.dart';

class RunningText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final Duration duration;

  const RunningText({
    super.key,
    required this.text,
    this.fontSize = 16.0,
    this.fontWeight = FontWeight.normal,
    this.color = Colors.black,
    this.textAlign = TextAlign.left,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.duration = const Duration(seconds: 5),
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: fontSize * 1.5, // Adjust height based on font size
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ListView(
            scrollDirection: Axis.horizontal,
            children: [
              AnimatedText(
                text: text,
                fontSize: fontSize,
                fontWeight: fontWeight,
                color: color,
                textAlign: textAlign,
                overflow: overflow,
                maxLines: maxLines,
                duration: duration,
                width: constraints.maxWidth,
              ),
            ],
          );
        },
      ),
    );
  }
}

class AnimatedText extends StatefulWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final Duration duration;
  final double width;

  const AnimatedText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.fontWeight,
    required this.color,
    required this.textAlign,
    required this.overflow,
    required this.maxLines,
    required this.duration,
    required this.width,
  });

  @override
  _AnimatedTextState createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> {
  late double textWidth;
  late double offset;

  @override
  void initState() {
    super.initState();
    textWidth = _calculateTextWidth(widget.text);
    offset = textWidth;
  }

  double _calculateTextWidth(String text) {
    final textSpan = TextSpan(
      text: text,
      style: TextStyle(
        fontSize: widget.fontSize,
        fontWeight: widget.fontWeight,
        color: widget.color,
      ),
    );
    final textPainter = TextPainter(
      text: textSpan,
      maxLines: widget.maxLines,
      textDirection: TextDirection.ltr,
      textAlign: widget.textAlign,
    )..layout();
    return textPainter.size.width;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ValueNotifier(offset)]),
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(offset, 0),
          child: Text(
            widget.text,
            style: TextStyle(
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              color: widget.color,
            ),
            textAlign: widget.textAlign,
            overflow: widget.overflow,
            maxLines: widget.maxLines,
          ),
        );
      },
    );
  }
}
