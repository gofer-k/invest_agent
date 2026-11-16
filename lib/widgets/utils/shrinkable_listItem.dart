import 'package:flutter/material.dart';

class ShrinkableListItem extends StatefulWidget {
  final String title;
  final List<Widget> details;
  final TextStyle? titleStyle;
  final bool expanded;

  const ShrinkableListItem({
    super.key,
    required this.title,
    required this.details,
    this.titleStyle,
    this.expanded = false,
  });

  @override
  State<ShrinkableListItem> createState() => _ShrinkableListItemState();
}

class _ShrinkableListItemState extends State<ShrinkableListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300), // Adjust duration
      vsync: this,
    );
    _isExpanded = widget.expanded;
  }

  @override
  void didUpdateWidget(covariant ShrinkableListItem oldWidget) {
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: _toggleExpand,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(widget.title,
                      style: widget.titleStyle ?? Theme.of(context).textTheme.titleMedium,)
                  ),
                  Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: const EdgeInsets.all(1.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: widget.details,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
    );
  }
}