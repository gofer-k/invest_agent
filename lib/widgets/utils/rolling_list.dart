import 'package:flutter/material.dart';

class RollingList<T> extends StatefulWidget {
  final List<T> values;
  final T initialValue;
  final void Function(T) onChanged;

  const RollingList({super.key, required this.values, required this.onChanged, required this.initialValue});

  @override
  State<StatefulWidget> createState() => _RollingListState<T>();
}

class _RollingListState<T> extends State<RollingList<T>> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    // Initialize the index based on the initialValue.
    _currentIndex = widget.values.indexOf(widget.initialValue);
    // Handle cases where the initial value might not be in the list.
    if (_currentIndex == -1) {
      _currentIndex = 0;
    }
  }

  bool get _canGoNext => _currentIndex < widget.values.length - 1;
  bool get _canGoPrevious => _currentIndex > 0;

  void _previous() {
    if (!_canGoPrevious) {
      return;
    }
    setState(() {
      _currentIndex--;
      widget.onChanged(widget.values[_currentIndex]);
    });
  }

  void _next() {
    if (!_canGoNext) {
      return;
    }
    setState(() {
      _currentIndex++;
      widget.onChanged(widget.values[_currentIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.values.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
        children: [
          Expanded(
            child: Align(alignment: Alignment.centerRight,
              child: IconButton(
                onPressed: _canGoPrevious ? _previous : null,
                icon: const Icon(Icons.navigate_before_rounded),
              ),
            ),
          ),
          SizedBox(width: 92,
            child: Text(widget.values[_currentIndex].toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Align(alignment: Alignment.centerLeft,
              child: IconButton(
                  onPressed: _canGoNext ? _next : null,
                  icon: const Icon(Icons.navigate_next_rounded)),
            ),
          ),
        ]
    );
  }
}