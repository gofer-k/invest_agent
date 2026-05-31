import 'package:flutter/material.dart';
import '../widgets/utils/dropdownlist.dart';

Widget choiceChartParameter<TParameter>(TextStyle? textStyle, Color backgroundColor,
    TParameter choiceParameter, List<TParameter> parameters,
    void Function(TParameter parameter) onSelected) {
  return DropdownList<TParameter>(
    textStyle: textStyle,
    backgroundColor:  backgroundColor,
    onSelected: (TParameter parameter) {
      if (choiceParameter == parameter) return;
      onSelected(parameter);
      choiceParameter = parameter;
    },
    choiceType: parameters.contains(choiceParameter)
        ? choiceParameter
        : parameters.first,
    choices: parameters,
  );
}