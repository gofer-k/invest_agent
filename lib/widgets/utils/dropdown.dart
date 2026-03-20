import 'package:flutter/material.dart';

class Dropdown<Choice extends Enum> extends StatefulWidget {
  final List<Choice> choices;
  final Function(Choice) onSelected;
  final Choice choiceType;
  const Dropdown({super.key,
    required this.onSelected,
    required this.choiceType,
    required this.choices});

  @override
  State<Dropdown<Choice>> createState() => _DropdownState<Choice>();
}

class _DropdownState<Choice extends Enum> extends State<Dropdown<Choice>> {
  // This is the currently selected item.
  late Choice _selectedItem;

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

    return DropdownButton<Choice>(
      // The hint text is shown when no item is selected.
      hint: const Text('Select an shape', style: dropdownTextStyle,),
      value: _selectedItem,
      icon: const Icon(Icons.arrow_downward),
      elevation: 2,
      isExpanded: true,
      dropdownColor: Colors.grey.shade800,
      style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black),
      items: widget.choices.map<DropdownMenuItem<Choice>>((Choice value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value.name, style: dropdownTextStyle),
        );
      }).toList(),
      onChanged: (Choice? newValue) {
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