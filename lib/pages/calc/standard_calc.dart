import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';
import 'package:rational/rational.dart';

import '../../utils/exact_calculator.dart';
import '../../utils/numeric_input.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StdCalc extends StatefulWidget {
  const StdCalc({super.key});

  @override
  State<StdCalc> createState() => _StdCalcState();

  void clearHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove("history_key");
    // Aggiorna lo stato o esegui altre operazioni necessarie
  }
}

class _StdCalcState extends State<StdCalc> {
  TextEditingController input = TextEditingController();
  final ScrollController _inputScroll = ScrollController();
  final FocusNode _inputFocus = FocusNode();

  var output = "";
  Rational? _lastResult;
  String? _lastResultText;

  void _trackResultEdits() {
    final text = _lastResultText;
    if (text == null) return;
    // Retain the full value only while the displayed result is an unchanged
    // first operand. Editing its digits starts a new numeric input.
    final current = input.text;
    if (current == text ||
        (current.startsWith(text) &&
            RegExp(
              r'^[+\-*/×÷%()]',
            ).hasMatch(current.substring(text.length)))) {
      return;
    }
    _lastResult = null;
    _lastResultText = null;
  }

  // HISTORY
  void addToHistory(input, output) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    var historyData = {
      "datetime": DateTime.now().toString(),
      "input": input,
      "output": output,
    };
    List history0 = jsonDecode(prefs.getString("history_key") ?? "[]");
    if (history0.length >= 100) {
      history0.removeAt(0);
      history0.add(historyData);
    } else {
      history0.add(historyData);
    }
    String history = jsonEncode(history0);
    await prefs.setString("history_key", history);
  }

  Future<List> listHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List listHistory = jsonDecode(prefs.getString("history_key") ?? "[]");

    return listHistory;
  }

  void scrollWithCursor(String val) {
    String blankText = "";
    final isLong = val.length > blankText.length;
    if (isLong) {
      _inputScroll.animateTo(
        _inputScroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
    print(_inputScroll.position.maxScrollExtent);
    print(input.selection.extentOffset);
  }

  void _doMath(String val) {
    if (val == "=") {
      if (input.text.isNotEmpty) {
        var userinput = input.text;
        final previousResult = _lastResult;
        if (previousResult != null && _lastResultText != null) {
          userinput = '(ans)${userinput.substring(_lastResultText!.length)}';
        }
        try {
          final finalvalue = ExactCalculator.evaluate(
            userinput,
            previous: previousResult,
          );
          final formattedOutput = ExactCalculator.format(finalvalue);
          setState(() {
            output = formattedOutput;
          });
          // History must remain evaluable without the transient ans binding.
          final historyInput = previousResult == null
              ? userinput
              : userinput.replaceAll(
                  'ans',
                  '(${ExactCalculator.serialize(previousResult)})',
                );
          addToHistory(historyInput, output);
          setState(() {
            input.value = TextEditingValue(
              text: output,
              selection: TextSelection.collapsed(offset: output.length),
            );
            _lastResult = finalvalue;
            _lastResultText = output;
          });
        } catch (e) {
          setState(() {
            output = AppLocalizations.of(context)!.syntaxError;
          });
        }
      }
      listHistory();
    } else if (val == "()") {
      if (!input.selection.isValid || input.selection.isCollapsed) {
        int cursor = input.selection.isValid && input.selection.baseOffset >= 0
            ? input.selection.baseOffset
            : input.text.length;

        String textBefore = input.text.substring(0, cursor);
        int openCount = 0;
        int closeCount = 0;
        for (int i = 0; i < textBefore.length; i++) {
          if (textBefore[i] == '(') openCount++;
          if (textBefore[i] == ')') closeCount++;
        }

        String toInsert = "(";
        if (textBefore.isNotEmpty) {
          String prevChar = textBefore[textBefore.length - 1];
          bool isDigitOrClosing = RegExp(r'[0-9\)]').hasMatch(prevChar);
          if (openCount > closeCount && isDigitOrClosing) {
            toInsert = ")";
          } else if (isDigitOrClosing) {
            toInsert = "*(";
          } else {
            toInsert = "(";
          }
        } else {
          toInsert = "(";
        }

        setState(() {
          if (input.selection.isValid && input.selection.baseOffset >= 0) {
            input.value = input.value.replaced(
              TextRange.collapsed(input.selection.baseOffset),
              toInsert,
            );
          } else {
            input.text = input.text + toInsert;
            input.selection = TextSelection.collapsed(
              offset: input.text.length,
            );
          }
        });
      } else {
        setState(() {
          input.value = input.value.replaced(
            TextRange(start: input.selection.start, end: input.selection.end),
            '(${input.text.substring(input.selection.start, input.selection.end)})',
          );
        });
        input.selection = TextSelection.fromPosition(
          TextPosition(offset: input.selection.end),
        );
      }
    } else {
      setState(() {
        insertNumericText(input, val, expression: true);
      });
    }
    _inputScroll.animateTo(
      _inputScroll.position.maxScrollExtent + 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void _bkspc() {
    if (input.text.isNotEmpty) {
      if (input.selection.isCollapsed) {
        if (input.selection.baseOffset == input.text.length) {
          setState(() {
            input.value = TextEditingValue(
              text: input.text.substring(0, input.text.length - 1),
            );
          });
          input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.text.length),
          );
        } else {
          setState(() {
            input.value = input.value.replaced(
              TextRange(
                start: input.selection.baseOffset - 1,
                end: input.selection.baseOffset,
              ),
              "",
            );
          });
          input.selection = TextSelection.fromPosition(
            TextPosition(offset: input.selection.start),
          );
        }
      } else {
        setState(() {
          input.value = input.value.replaced(
            TextRange(start: input.selection.start, end: input.selection.end),
            "",
          );
        });
        input.selection = TextSelection.fromPosition(
          TextPosition(offset: input.selection.end),
        );
      }
    } else {
      setState(() {
        input.clear();
        output = input.text;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    input.addListener(_trackResultEdits);
    setState(() {
      input.value = const TextEditingValue(
        selection: TextSelection.collapsed(offset: 0),
      );
    });
  }

  @override
  void dispose() {
    super.dispose();
    input.dispose();
    _inputScroll.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                          child: Column(
                            children: [
                              Expanded(child: _inputView(context)),
                              Expanded(child: _history(context, false)),
                            ],
                          ),
                        ),
                        Expanded(child: _keypad(context, 1.046)),
                      ],
                    );
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: _history(context, false)),
                              Expanded(child: _inputView(context)),
                            ],
                          ),
                        ),
                        _keypad(context, 2),
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
                      Expanded(child: _inputView(context)),
                      Expanded(child: _keypad(context, 1.8)),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Expanded(flex: 1, child: _inputView(context)),
                      _keypad(context, (1 / 1)),
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

  Widget _inputView(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
          padding: const EdgeInsets.all(8),
          margin: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextField(
                enableSuggestions: false,
                autofocus: true,
                textAlign: TextAlign.right,
                decoration: const InputDecoration(border: InputBorder.none),
                controller: input,
                focusNode: _inputFocus,
                scrollController: _inputScroll,
                inputFormatters: [
                  const NumericInputFormatter(expression: true),
                ],
                style: const TextStyle(fontSize: 48),
                keyboardType: TextInputType.none,
              ),
              const Divider(),
              const SizedBox(height: 10),
              Text(output.toString(), style: const TextStyle(fontSize: 30)),
            ],
          ),
        ),
        getDeviceType(
                  Size(
                    MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height,
                  ),
                ) ==
                DeviceScreenType.tablet
            ? const SizedBox.shrink()
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => Dialog.fullscreen(
                        child: Column(
                          children: [
                            AppBar(
                              leading: IconButton(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                            Expanded(child: _history(context, true)),
                          ],
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history),
                ),
              ),
      ],
    );
  }

  Widget _keypad(BuildContext context, double cellSizeRatio) {
    return GridView(
      padding: const EdgeInsets.all(8),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: cellSizeRatio,
      ),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        FilledButton(
          onPressed: () {
            setState(() {
              input.clear();
              output = input.text;
              HapticFeedback.lightImpact();
            });
          },
          child: const Text("C", style: TextStyle(fontSize: 32)),
        ),
        _buildCalcButton("()", true),
        _buildCalcButton("%", true),
        _buildCalcButton("÷", true),
        _buildCalcButton("7", false),
        _buildCalcButton("8", false),
        _buildCalcButton("9", false),
        _buildCalcButton("\u00d7", true),
        _buildCalcButton("4", false),
        _buildCalcButton("5", false),
        _buildCalcButton("6", false),
        _buildCalcButton("\u2013", true),
        _buildCalcButton("1", false),
        _buildCalcButton("2", false),
        _buildCalcButton("3", false),
        _buildCalcButton("+", true),
        _buildCalcButton("0", false),
        _buildCalcButton(".", false),
        FilledButton.tonal(
          onPressed: () {
            _bkspc();

            HapticFeedback.lightImpact();
          },
          child: const Icon(Icons.backspace_outlined, size: 32),
        ),
        _buildCalcButton("=", true),
      ],
    );
  }

  Widget _history(BuildContext context, bool isPhone) {
    bool isPhone = true;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Theme.of(context).colorScheme.secondaryContainer,
      ),
      padding: const EdgeInsets.all(8),
      margin: const EdgeInsets.all(8),
      child: FutureBuilder(
        future: listHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(AppLocalizations.of(context)!.historyEmpty),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              var math = snapshot.data?[index];
              return ListTile(
                title: InkWell(
                  onTap: () {
                    input.clear();

                    setState(() {
                      output = "";
                      input.value = input.value.replaced(
                        TextRange.collapsed(input.selection.baseOffset),
                        math["input"],
                      );
                    });
                    if (isPhone) {
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    math["input"],
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                ),
                subtitle: Text(
                  math["output"],
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCalcButton(String val, bool notTonalButton) {
    String valb;
    if (val == "\u2013") {
      valb = "-";
    } else if (val == "÷") {
      valb = "/";
    } else {
      valb = val;
    }

    return notTonalButton
        ? FilledButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              _doMath(valb);
            },
            child: Text(val, style: const TextStyle(fontSize: 32)),
          )
        : FilledButton.tonal(
            onPressed: () {
              HapticFeedback.lightImpact();
              _doMath(valb);
            },
            child: Text(val, style: const TextStyle(fontSize: 32)),
          );
  }
}
