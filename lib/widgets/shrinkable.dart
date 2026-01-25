import 'package:flutter/material.dart';

class Shrinkable extends StatefulWidget {
  final String title;
  final Widget body;
  final TextStyle? titleStyle;
  final bool expanded;

  const Shrinkable({
    super.key,
    required this.title,
    required this.body,
    this.titleStyle,
    this.expanded = false
  });

  @override
  State<Shrinkable> createState() => _ShrinkableState();
}

class _ShrinkableState extends State<Shrinkable>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.expanded;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Adjust duration
      vsync: this,
    );
  }

  @override
  void didUpdateWidget(covariant Shrinkable oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the parent widget's `expanded` property changes, update the internal state
    if (widget.expanded != oldWidget.expanded) {
      setState(() {
        _isExpanded = widget.expanded;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward(); // Play animation to expand
      } else {
        _controller.reverse(); // Play animation to collapse
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: _toggleExpand,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(widget.title,
                  style: widget.titleStyle ?? Theme.of(context).textTheme.titleMedium,),
                Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _isExpanded ? widget.body : const SizedBox.shrink(),
        ),
      ]
    );
  }
}
