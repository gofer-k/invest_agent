import 'package:flutter/material.dart';

class DropdownList<T> extends StatefulWidget {
  final List<T> choices;
  final Function(T) onSelected;
  final T choiceType;
  final String? hint;
  final bool isExpanded;
  final TextStyle? textStyle;
  final Color backgroundColor;

  const DropdownList({
    super.key,
    required this.onSelected,
    required this.choiceType,
    required this.choices,
    required this.backgroundColor,
    this.hint,
    this.isExpanded = false,
    this.textStyle,
  });

  @override
  State<DropdownList<T>> createState() => _DropdownListState<T>();
}

class _DropdownListState<T> extends State<DropdownList<T>> {
  // This is the currently selected item.
  late T _selectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.choiceType;
  }

  @override
  void didUpdateWidget(covariant DropdownList<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.choiceType != oldWidget.choiceType) {
      _selectedItem = widget.choiceType;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dropdownTextStyle = widget.textStyle ?? TextStyle(
      fontSize: 18.0, // Increased font size
      color: Colors.white70, // A whitish color (you can adjust opacity or use Colors.white)
    );

    // Ensure the selected item is actually in the choices list to avoid Flutter assertion errors
    T? effectiveValue = widget.choices.contains(_selectedItem) ? _selectedItem : null;

    return DropdownButton<T>(
      // The hint text is shown when no item is selected.
      // Shrink the list's elements space as short as possible.
      hint: widget.hint != null ? Text(widget.hint!, style: dropdownTextStyle) : null,
      value: effectiveValue,
      icon:  const Icon(Icons.expand_more, size: 20),
      elevation: 2,
      isExpanded: widget.isExpanded,
      isDense: true,
      padding: EdgeInsets.zero,
      alignment: Alignment.centerLeft,
      dropdownColor: widget.backgroundColor,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
      selectedItemBuilder: (BuildContext context) {
        return widget.choices.map<Widget>((T value) {
          return Container(
            alignment: Alignment.centerLeft,
            child: Text(value.toString().trim(), style: dropdownTextStyle),
          );
        }).toList();
      },
      items: widget.choices.map<DropdownMenuItem<T>>((T value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.toString(), style: dropdownTextStyle),
        );
      }).toList(),
      onChanged: (T? newValue) {
        if (newValue != null) {
          setState(() {
            _selectedItem = newValue;
            widget.onSelected(newValue);
          });
        }
      },
    );
  }
}
