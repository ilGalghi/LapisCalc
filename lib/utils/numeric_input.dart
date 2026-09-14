import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Shared by the on-screen keypad and pasted/hardware-keyboard input.
class NumericInputFormatter extends TextInputFormatter {
  const NumericInputFormatter({this.expression = false});

  final bool expression;
  static final _number = RegExp(r'(?:\d+(?:\.\d*)?|\.\d*)(?:[eE][+\-]?\d*)?');
  static final _singleNumber =
      RegExp(r'^-?(?:\d+(?:\.\d*)?|\.\d*)(?:[eE][+\-]?\d*)?$');

  bool accepts(String text) {
    if (!expression) {
      return text.isEmpty || text == '-' || _singleNumber.hasMatch(text);
    }
    String? previous;
    var offset = 0;
    while (offset < text.length) {
      final char = text[offset];
      if (char.trim().isEmpty) {
        offset++;
        continue;
      }
      final number = _number.matchAsPrefix(text, offset);
      if (number != null) {
        // A second decimal point would start another number without an operator.
        if (previous == 'number') return false;
        previous = 'number';
        offset = number.end;
        continue;
      }
      if ('+-–*/×÷^'.contains(char)) {
        if (previous == 'operator') return false;
        if ((previous == null || previous == '(') && char != '-') return false;
        previous = 'operator';
      } else if (char == '%') {
        if (previous != 'number' && previous != ')' && previous != '%') {
          return false;
        }
        previous = '%';
      } else if (char == '(' || char == ')') {
        previous = char;
      } else {
        return false;
      }
      offset++;
    }
    return true;
  }

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return accepts(newValue.text) ? newValue : oldValue;
  }
}

void insertNumericText(TextEditingController controller, String text,
    {bool expression = false}) {
  final oldValue = controller.value;
  final selection = oldValue.selection;
  final start = selection.isValid ? selection.start : oldValue.text.length;
  final end = selection.isValid ? selection.end : oldValue.text.length;
  final proposed = TextEditingValue(
    text: oldValue.text.replaceRange(start, end, text),
    selection: TextSelection.collapsed(offset: start + text.length),
  );
  controller.value = NumericInputFormatter(expression: expression)
      .formatEditUpdate(oldValue, proposed);
}
