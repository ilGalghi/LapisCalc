import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/settings_model.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';


class TipConv extends StatefulWidget {
  const TipConv({super.key});
  static String pageTitle = "Tip";

  @override
  State<TipConv> createState() => _TipCalculatorState();
}

class _TipCalculatorState extends State<TipConv> {
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();
  final TextEditingController _tipPercentageController = TextEditingController();
  final FocusNode _tipPercentageFocusNode = FocusNode();
  final TextEditingController _tipAmountController = TextEditingController();
  final TextEditingController _totalAmountController = TextEditingController();
  final FocusNode _totalAmountFocusNode = FocusNode();


  @override
  void initState() {
    super.initState();
    _amountFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _amountFocusNode.dispose();
    _tipPercentageController.dispose();
    _tipPercentageFocusNode.dispose();
    _tipAmountController.dispose();
    super.dispose();
  }

  double _calculateTipAmount() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double tipPercentage = double.tryParse(_tipPercentageController.text) ?? 0.0;
    return amount * (tipPercentage / 100);
  }

  double _calculateTotalAmount() {
    double amount = double.tryParse(_amountController.text) ?? 0.0;
    double tipAmount = double.tryParse(_tipAmountController.text) ?? 0.0;
    return amount + tipAmount;
  }

  void _updateTotalAmount() {
    double totalAmount = _calculateTotalAmount();
    _totalAmountController.text = totalAmount.toStringAsFixed(2);
  }

  void _updateTipAmount() {
    double tipAmount = _calculateTipAmount();
    _tipAmountController.text = tipAmount.toStringAsFixed(2);
    _updateTotalAmount();
  }


  void _clear() {
    _amountController.clear();
    _tipPercentageController.clear();
    _tipAmountController.clear();
    _totalAmountController.clear();
  }

  void _switchFocus() {
    if (_tipPercentageFocusNode.hasFocus) {
      _tipPercentageFocusNode.unfocus();
      _amountFocusNode.requestFocus();
    } else if (_amountFocusNode.hasFocus) {
      _amountFocusNode.unfocus();
      _tipPercentageFocusNode.requestFocus();
    }
  }

  void _appendDigit(String digit) {
    if (_amountFocusNode.hasFocus) {
      _amountController.text += digit;
    } else if (_tipPercentageFocusNode.hasFocus) {
      _tipPercentageController.text += digit;
    }
    _updateTipAmount();
  }

  void _appendDecimal() {
    if (_amountFocusNode.hasFocus) {
      if (!_amountController.text.contains('.')) {
        _amountController.text += '.';
      }
    } else if (_tipPercentageFocusNode.hasFocus) {
      if (!_tipPercentageController.text.contains('.')) {
        _tipPercentageController.text += '.';
      }
    }
    _updateTipAmount();
  }

  void _backspace() {
    if (_amountFocusNode.hasFocus) {
      if (_amountController.text.isNotEmpty) {
        _amountController.text =
            _amountController.text.substring(0, _amountController.text.length - 1);
      }
    } else if (_tipPercentageFocusNode.hasFocus) {
      if (_tipPercentageController.text.isNotEmpty) {
        _tipPercentageController.text = _tipPercentageController.text.substring(
            0, _tipPercentageController.text.length - 1);
      }
    }
    _updateTipAmount();
  }



  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            if (sizingInformation.deviceScreenType == DeviceScreenType.tablet) {
              return OrientationBuilder(
                builder: (context, orientation) {
                  if (orientation == Orientation.landscape) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _inputView(context, 48),
                        ),
                        Expanded(child: _keypad(context, 1.42))
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _inputView(context, 48),
                        ),
                        _keypad(context, 2)
                      ],
                    );
                  }
                },
              );
            }
            return OrientationBuilder(
              builder: (context, orientation) {
                if (orientation == Orientation.landscape) {
                  return Row(
                    children: [
                      Expanded(child: _inputView(context, 32)),
                      Expanded(child: _keypad(context, 2.4)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(
                        flex: 1,
                        child: _inputView(context, 48),
                      ),
                      _keypad(context, 1.8)
                    ],
                  );
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _keypad(BuildContext context, double cellSizeRatio) {
    return GridView(
      shrinkWrap: true,
      padding: const EdgeInsets.all(8),
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: cellSizeRatio),
      children: [
      FilledButton(
      onPressed: _switchFocus,
      child: Transform.rotate(
        angle: 90 * pi / 180,
        child: const Icon(
          Icons.compare_arrows,
          size: 32,
        ),
      ),
    ),
     _buildButtons("C", false, _clear),
     FilledButton(
        onPressed: () {
          _backspace();
          HapticFeedback.lightImpact();
        },
      child: const Icon(
        Icons.backspace_outlined,
        size: 32,
        ),
      ),
    _buildButtons("7", true, () => _appendDigit('7')),
    _buildButtons("8", true, () => _appendDigit('8')),
    _buildButtons("9", true, () => _appendDigit('9')),
    _buildButtons("4", true, () => _appendDigit('4')),
    _buildButtons("5", true, () => _appendDigit('5')),
    _buildButtons("6", true, () => _appendDigit('6')),
    _buildButtons("1", true, () => _appendDigit('1')),
    _buildButtons("2", true, () => _appendDigit('2')),
    _buildButtons("3", true, () => _appendDigit('3')),
    const FilledButton.tonal(
    onPressed: null,
    child: Text(
    "\u00b1",
    style: TextStyle(
    fontSize: 32,
    ),
    ),
    ),
    _buildButtons("0", true, () => _appendDigit('0')),
        _buildButtons(".", true, _appendDecimal),
      ],
    );
  }

  Widget _inputView(BuildContext context, double fontSize) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: AppLocalizations.of(context)!.amount,    //AMOUNT
              ),
              controller: _amountController,
              focusNode: _amountFocusNode, // Aggiungi questa riga
              onChanged: (_) => _updateTipAmount(), // Aggiungi questa riga
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z:$]'))
              ],
              style: TextStyle(
                fontSize: fontSize,
              ),
              keyboardType: TextInputType.none,      // TOGLIE TASTIERA DI SISTEMA
            ),
          ),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: AppLocalizations.of(context)!.tippercentage,
              ),
              controller: _tipPercentageController,
              focusNode: _tipPercentageFocusNode,
              onChanged: (_) => _updateTipAmount(),
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z:$]'))
              ],
              style: TextStyle(
                fontSize: fontSize,
              ),
              keyboardType: TextInputType.none,     // TOGLIE TASTIERA DI SISTEMA
            ),
          ),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: AppLocalizations.of(context)!.tipamount,
              ),
              controller: _tipAmountController,
              readOnly: true,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),

          Expanded(
            child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                labelText: AppLocalizations.of(context)!.totalamount,
              ),
              controller: _totalAmountController,
              focusNode: _totalAmountFocusNode,
              readOnly: true,
              style: TextStyle(
                fontSize: fontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(String label, bool tonal, void Function() onPressed) {
    return SizedBox(
      height: 32,
      width: 72,
      child: tonal
          ? FilledButton.tonal(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 32,
          ),
        ),
      )
          : FilledButton(
        onPressed: onPressed,
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 32,
          ),
        ),
      ),
    );
  }
}