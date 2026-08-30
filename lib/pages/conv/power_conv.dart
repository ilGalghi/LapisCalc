import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:units_converter/units_converter.dart';

import '../../models/settings_model.dart';
import '../settings_page.dart';

class PowerConv extends StatefulWidget {
  const PowerConv({super.key});
  static String pageTitle = "Power";

  @override
  State<PowerConv> createState() => _PowerConvState();
}

class _PowerConvState extends State<PowerConv> {
  TextEditingController inputA = TextEditingController();
  FocusNode inputAFN = FocusNode();
  TextEditingController inputB = TextEditingController();
  FocusNode inputBFN = FocusNode();

  bool isInputA = true;
  var selectedpowerA;
  var selectedpowerB;
  var selectedpowerSymbolA;
  var selectedpowerSymbolB;
  var power = Power(significantFigures: 7, removeTrailingZeros: true);
  var units = [];
  Map<dynamic, String> unitDetails = {};

  void _convValueBuild(unitsconv) {
    for (Unit unit in unitsconv) {
      if (unit.name == selectedpowerA) {
        selectedpowerSymbolA = unit.symbol;
      }
      if (unit.name == selectedpowerB) {
        selectedpowerSymbolB = unit.symbol;
      }
      unitDetails[unit.name] = unit.stringValue ?? "";
    }
  }

  void _recalculate() {
    if (isInputA) {
      if (inputA.text.isNotEmpty && double.tryParse(inputA.text) != null) {
        power.convert(selectedpowerA, double.parse(inputA.text));
        units = power.getAll();
        _convValueBuild(units);
        inputB.text = unitDetails[selectedpowerB] ?? "";
      } else {
        units = power.getAll();
        _convValueBuild(units);
        if (inputA.text.isEmpty) {
          inputB.clear();
        }
      }
    } else {
      if (inputB.text.isNotEmpty && double.tryParse(inputB.text) != null) {
        power.convert(selectedpowerB, double.parse(inputB.text));
        units = power.getAll();
        _convValueBuild(units);
        inputA.text = unitDetails[selectedpowerA] ?? "";
      } else {
        units = power.getAll();
        _convValueBuild(units);
        if (inputB.text.isEmpty) {
          inputA.clear();
        }
      }
    }
  }

  void _bkspc() {
    setState(() {
      if (isInputA) {
        if (inputA.text.isNotEmpty) {
          if (inputA.selection.isCollapsed) {
            if (inputA.selection.baseOffset == inputA.text.length ||
                inputA.selection.baseOffset < 0) {
              inputA.text = inputA.text.substring(0, inputA.text.length - 1);
              inputA.selection = TextSelection.fromPosition(
                  TextPosition(offset: inputA.text.length));
            } else if (inputA.selection.baseOffset > 0) {
              final int offset = inputA.selection.baseOffset;
              inputA.value = inputA.value.replaced(
                  TextRange(start: offset - 1, end: offset), "");
              inputA.selection =
                  TextSelection.fromPosition(TextPosition(offset: offset - 1));
            }
          } else {
            final int start = inputA.selection.start;
            inputA.value = inputA.value.replaced(
                TextRange(start: start, end: inputA.selection.end), "");
            inputA.selection =
                TextSelection.fromPosition(TextPosition(offset: start));
          }
        }
      } else {
        if (inputB.text.isNotEmpty) {
          if (inputB.selection.isCollapsed) {
            if (inputB.selection.baseOffset == inputB.text.length ||
                inputB.selection.baseOffset < 0) {
              inputB.text = inputB.text.substring(0, inputB.text.length - 1);
              inputB.selection = TextSelection.fromPosition(
                  TextPosition(offset: inputB.text.length));
            } else if (inputB.selection.baseOffset > 0) {
              final int offset = inputB.selection.baseOffset;
              inputB.value = inputB.value.replaced(
                  TextRange(start: offset - 1, end: offset), "");
              inputB.selection =
                  TextSelection.fromPosition(TextPosition(offset: offset - 1));
            }
          } else {
            final int start = inputB.selection.start;
            inputB.value = inputB.value.replaced(
                TextRange(start: start, end: inputB.selection.end), "");
            inputB.selection =
                TextSelection.fromPosition(TextPosition(offset: start));
          }
        }
      }
      _recalculate();
    });
  }

  void _convFunc(val) {
    if (val == "C") {
      setState(() {
        inputA.clear();
        inputB.clear();
        units = power.getAll();
        _convValueBuild(units);
      });
    } else {
      setState(() {
        if (isInputA) {
          if (inputA.selection.start >= 0 && inputA.selection.end >= 0) {
            inputA.value = TextEditingValue(
              text: inputA.text.replaceRange(
                  inputA.selection.start, inputA.selection.end, val.toString()),
              selection: TextSelection.collapsed(
                  offset: inputA.selection.start + val.toString().length),
            );
          } else {
            inputA.text = inputA.text + val.toString();
            inputA.selection = TextSelection.fromPosition(
                TextPosition(offset: inputA.text.length));
          }
        } else {
          if (inputB.selection.start >= 0 && inputB.selection.end >= 0) {
            inputB.value = TextEditingValue(
              text: inputB.text.replaceRange(
                  inputB.selection.start, inputB.selection.end, val.toString()),
              selection: TextSelection.collapsed(
                  offset: inputB.selection.start + val.toString().length),
            );
          } else {
            inputB.text = inputB.text + val.toString();
            inputB.selection = TextSelection.fromPosition(
                TextPosition(offset: inputB.text.length));
          }
        }
        _recalculate();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    isInputA = true;
    inputAFN.addListener(() {
      if (inputAFN.hasFocus) {
        setState(() {
          isInputA = true;
        });
      }
    });
    inputBFN.addListener(() {
      if (inputBFN.hasFocus) {
        setState(() {
          isInputA = false;
        });
      }
    });
    selectedpowerA = POWER.watt;
    selectedpowerB = POWER.kilowatt;
    units = power.getAll();
    _convValueBuild(units);
    inputAFN.requestFocus();
  }

  @override
  void dispose() {
    inputA.dispose();
    inputAFN.dispose();
    inputB.dispose();
    inputBFN.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SettingsModel settings = Provider.of<SettingsModel>(context);
    power.significantFigures = settings.sigFig;
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
            onPressed: () {
              setState(() {
                if (isInputA) {
                  inputAFN.unfocus();
                  inputBFN.requestFocus();
                  isInputA = false;
                } else {
                  inputBFN.unfocus();
                  inputAFN.requestFocus();
                  isInputA = true;
                }
              });
            },
            child: Transform.rotate(
              angle: 90 * pi / 180,
              child: const Icon(
                Icons.compare_arrows,
                size: 32,
              ),
            )),
        _buildButtons("C", false),
        FilledButton(
            onPressed: () {
              _bkspc();

              HapticFeedback.lightImpact();
            },
            child: const Icon(
              Icons.backspace_outlined,
              size: 32,
            )),
        _buildButtons("7", true),
        _buildButtons("8", true),
        _buildButtons("9", true),
        _buildButtons("4", true),
        _buildButtons("5", true),
        _buildButtons("6", true),
        _buildButtons("1", true),
        _buildButtons("2", true),
        _buildButtons("3", true),
        const FilledButton.tonal(
            onPressed: null,
            child: Text(
              "\u00b1",
              style: TextStyle(
                fontSize: 32,
              ),
            )),
        _buildButtons("0", true),
        _buildButtons(".", true),
      ],
    );
  }

  Widget _inputView(BuildContext context, double fontsize) {
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
            child: DropdownMenu(
                dropdownMenuEntries: List.generate(
                  units.length,
                  growable: false,
                  (index) {
                    var unit = units[index];
                    return DropdownMenuEntry(
                      value: unit.name,
                      label: unit.name.toString().split("POWER.").last.capitalize(),
                    );
                  },
                ),
                initialSelection: selectedpowerA,
                onSelected: (value) {
                  setState(() {
                    selectedpowerA = value;
                    _recalculate();
                  });
                },
              ),
          ),
          Expanded(
            child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: selectedpowerSymbolA.toString(),
              ),
              controller: inputA,
              focusNode: inputAFN,
              onTap: () {
                setState(() {
                  isInputA = true;
                });
              },
              onChanged: (value) {
                setState(() {
                  isInputA = true;
                  _recalculate();
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
              ],
              style: TextStyle(
                fontSize: fontsize,
              ),
              keyboardType: TextInputType.none,
            ),
          ),
          const Divider(),
          Expanded(
            child: DropdownMenu(
              dropdownMenuEntries: List.generate(
                units.length,
                growable: false,
                (index) {
                  var unit = units[index];
                  return DropdownMenuEntry(
                    value: unit.name,
                    label: unit.name.toString().split("POWER.").last.capitalize(),
                  );
                },
              ),
              initialSelection: selectedpowerB,
              onSelected: (value) {
                setState(() {
                  selectedpowerB = value;
                  _recalculate();
                });
              },
            ),
          ),
          Expanded(
          child: TextField(
              enableSuggestions: false,
              textAlign: TextAlign.right,
              decoration: InputDecoration(
                border: InputBorder.none,
                suffixText: selectedpowerSymbolB.toString(),
              ),
              controller: inputB,
              focusNode: inputBFN,
              onTap: () {
                setState(() {
                  isInputA = false;
                });
              },
              onChanged: (value) {
                setState(() {
                  isInputA = false;
                  _recalculate();
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'[a-z] [A-Z] :$'))
              ],
              style: TextStyle(
                fontSize: fontsize,
              ),
              keyboardType: TextInputType.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButtons(String label, bool tonal) {
    return tonal
        ? SizedBox(
            height: 32,
            width: 72,
            child: FilledButton.tonal(
                onPressed: () {
                  _convFunc(label);
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                )),
          )
        : SizedBox(
            height: 32,
            width: 72,
            child: FilledButton(
                onPressed: () {
                  _convFunc(label);
                  HapticFeedback.lightImpact();
                },
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 32,
                  ),
                )),
          );
  }
}
