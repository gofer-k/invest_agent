import 'package:flutter/material.dart';

class DropdownList<T> extends StatefulWidget {
  final List<T> choices;
  final Function(T) onSelected;
  final T choiceType;
  final String? hint;
  const DropdownList({super.key,
    required this.onSelected,
    required this.choiceType,
    required this.choices,
    this.hint});

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
  Widget build(BuildContext context) {
    const TextStyle dropdownTextStyle = TextStyle(
      fontSize: 18.0, // Increased font size
      color: Colors.white70, // A whitish color (you can adjust opacity or use Colors.white)
    );

    return DropdownButton<T>(
      // The hint text is shown when no item is selected.
      hint: Text(widget.hint ?? 'Select an shape', style: dropdownTextStyle,),
      value: _selectedItem,
      icon: const Icon(Icons.arrow_downward),
      elevation: 2,
      isExpanded: true,
      dropdownColor: Colors.grey.shade800,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
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
