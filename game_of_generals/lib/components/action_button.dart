import 'package:flutter/material.dart';

class ActionButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const ActionButton({super.key, required this.child, this.onTap});

  @override
  ActionButtonState createState() => ActionButtonState();
}

class ActionButtonState extends State<ActionButton> {
  double scale = 1.0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      onHover: (isHovering) {
        setState(() {
          scale = isHovering ? 0.9 : 1.0;
        });
      },
      child: AnimatedScale(
        curve: Curves.fastEaseInToSlowEaseOut,
        duration: const Duration(milliseconds: 200),
        scale: scale,
        child: widget.child,
      ),
    );
  }
}
