import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../model/results/strategies/strategy_schema.dart';
import '../utils/dropdown.dart';

void showStrategy(BuildContext context, Strategy? strategy, Function(Strategy? strategy) onSave) {
  showDialog(context: context,
    builder: (BuildContext context) {
      return StrategyDialog(strategy: strategy, onSave: onSave);
    }
  );
}

class StrategyDialog extends ConsumerStatefulWidget {
  final Function(Strategy? strategy) onSave;
  final Strategy? strategy;
  const StrategyDialog({super.key, required this.onSave, required this.strategy});

  @override
  ConsumerState<StrategyDialog> createState() => _StrategyDialogState();
}

class _StrategyDialogState extends ConsumerState<StrategyDialog> {
  late final TextEditingController controllerName;
  late Map<String, dynamic> parameters = {};
  bool addingParameter = false;
  StrategyType _selectedType = StrategyType.empty;

  @override
  void initState() {
    super.initState();
    controllerName = TextEditingController(text:  widget.strategy?.name ?? '');
  }

  @override
  void dispose() {
    controllerName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text("Strategy: ${widget.strategy?.name ?? 'New'}"),
      content: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _selectStrategy(),
              const SizedBox(height: 8),
              _strategyContents()
            ],
          )
        ),
      ),
    );
  }

  Widget _selectStrategy() {
    return Dropdown<StrategyType>(
      onSelected: (StrategyType newType) {
        setState(() => _selectedType = newType);
      },
      choices:StrategyType.values,
      choiceType: _selectedType,
    );
  }

  Widget _strategyContents() {
    return Container();
  }
}