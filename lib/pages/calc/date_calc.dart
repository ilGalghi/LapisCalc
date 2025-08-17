import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';

class DateCalc extends StatefulWidget {
  const DateCalc({super.key});
  static String pageTitle = "Date";

  @override
  State<DateCalc> createState() => _DateCalcState();
}

//TABBAR -----------------------------------------------------------------------
class _DateCalcState extends State<DateCalc>
    with AutomaticKeepAliveClientMixin<DateCalc> {
  final List<Widget> _pages = [const BuildDateDiff(), const AddSubdays()];
  int selectedIndex = 0;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: _pages.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: TabBar(tabs: [
          Tab(
            text: AppLocalizations.of(context)!.datedifference
          ),
          Tab(
            text: AppLocalizations.of(context)!.addsubtractdays
          )
        ]),
        body: SafeArea(child: TabBarView(children: _pages)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BuildDateDiff extends StatefulWidget {
  const BuildDateDiff({super.key});

  @override
  State<BuildDateDiff> createState() => _BuildDateDiffState();
}

class _BuildDateDiffState extends State<BuildDateDiff>
    with AutomaticKeepAliveClientMixin<BuildDateDiff> {
  DateTime selectedDate1 = DateTime.now();
  DateTime selectedDate2 = DateTime.now();
  Future<void> _selectDate1(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate1,
      firstDate: DateTime(1600, 1, 1),
      lastDate: DateTime(2550, 12, 31),
    );
    if (picked != null && picked != selectedDate1) {
      setState(() {
        selectedDate1 = picked;
      });
    }
  }

  Future<void> _selectDate2(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate2,
      firstDate: DateTime(1600, 1, 1),
      lastDate: DateTime(2550, 12, 31),
    );
    if (picked != null && picked != selectedDate2) {
      setState(() {
        selectedDate2 = picked;
      });
    }
  }

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return to.difference(from).inMilliseconds.abs();
  }

  String formatMilliseconds(int milliseconds) {
    // Number of milliseconds in a day, week, month, and year
    const int millisecondsPerDay = 86400000;
    const int millisecondsPerWeek = 604800000;
    const int millisecondsPerMonth = 2629800000;
    const int millisecondsPerYear = 31557600000;

    int years = milliseconds ~/ millisecondsPerYear;
    int months = (milliseconds % millisecondsPerYear) ~/ millisecondsPerMonth;
    int weeks = ((milliseconds % millisecondsPerYear) % millisecondsPerMonth) ~/
        millisecondsPerWeek;
    int days = (((milliseconds % millisecondsPerYear) % millisecondsPerMonth) %
            millisecondsPerWeek) ~/
        millisecondsPerDay;

    String result = '';
    if (years > 0) {
      result += '${years.toString()} ${years == 1 ? (AppLocalizations.of(context)!.year) : (AppLocalizations.of(context)!.years)}';
    }
    if (months > 0) {
      result +=
          '${result.isNotEmpty ? ', ' : ''}${months.toString()} ${months == 1 ? (AppLocalizations.of(context)!.month) : (AppLocalizations.of(context)!.months)}';
    }
    if (weeks > 0) {
      result +=
          '${result.isNotEmpty ? ', ' : ''}${weeks.toString()} ${weeks == 1 ? (AppLocalizations.of(context)!.week) : (AppLocalizations.of(context)!.weeks)}';
    }
    if (days > 0) {
      result +=
          '${result.isNotEmpty ? ', ' : ''}${days.toString()} ${days == 1 ? (AppLocalizations.of(context)!.day) : (AppLocalizations.of(context)!.days)}';
    }

    if (weeks > 0 || months > 0 || years > 0) {
      return "$result (${daysBetween(selectedDate1, selectedDate2)~/86400000}  ${AppLocalizations.of(context)!.days})";
    }
    else{
      return result;
    }
  }

  // SEZIONE "FROM - TO" -------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.from, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            InkWell(
              child: Chip(
                  label: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(Icons.date_range_outlined),
                    Text(DateFormat.yMMMd().format(selectedDate1).toString()),
                ],
              )),
              onTap: () => _selectDate1(context),
            ),
            const SizedBox(
              height: 36,
            ),
            Text(AppLocalizations.of(context)!.to, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            InkWell(
              child: Chip(
                  label: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.date_range_outlined),
                    Text(DateFormat.yMMMd().format(selectedDate2).toString()),
                ],
              )),
              onTap: () => _selectDate2(context),
            ),
            const SizedBox(
              height: 36,
            ),
            Text(AppLocalizations.of(context)!.difference, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            selectedDate1.difference(selectedDate2).inMilliseconds == 0
                ? Text(
                    AppLocalizations.of(context)!.sameday,
                    style: const TextStyle(fontSize: 36),
                  )
                : Text(
                    formatMilliseconds(
                        daysBetween(selectedDate1, selectedDate2)),
                        style: const TextStyle(fontSize: 36),
                    )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class AddSubdays extends StatefulWidget {
  const AddSubdays({super.key});

  @override
  State<AddSubdays> createState() => _AddSubdaysState();
}

class _AddSubdaysState extends State<AddSubdays>
    with AutomaticKeepAliveClientMixin<AddSubdays> {
  DateTime fromDate = DateTime.now();
  int newSelectedYear = 0;
  int newSelectedMonth = 0;
  int newSelectedDay = 0;

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: DateTime(1600, 1, 1),
      lastDate: DateTime(2550, 12, 31),
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked;
      });
    }
  }

  //AGGIUNTA E SOTTRAZIONE DELLA DATA ------------------------------------------
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(AppLocalizations.of(context)!.from, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            InkWell(
              child: Chip(
                  label: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   const Icon(Icons.date_range_outlined),
                   Text(DateFormat.yMMMd(Localizations.localeOf(context).languageCode).format(fromDate).toString()),
                ],
              )),
              onTap: () => _selectDate(context),
            ),
            const SizedBox(
              height: 36,
            ),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DropdownMenu(
                  width: 96,
                  dropdownMenuEntries: List.generate(
                      99,
                      (index) => DropdownMenuEntry(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size.fromWidth(96),
                              ),
                            ),
                            value: index,
                            label: index.toString(),
                          ),
                      growable: false),
                  initialSelection: 0,
                  label: Text(AppLocalizations.of(context)!.yearM),
                  onSelected: (value) => setState(() {
                    newSelectedYear = value!;
                  }),
                ),
                DropdownMenu(
                  width: 96,
                  dropdownMenuEntries: List.generate(
                      99,
                      (index) => DropdownMenuEntry(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size.fromWidth(96),
                              ),
                            ),
                            value: index,
                            label: index.toString(),
                          ),
                      growable: false),
                  initialSelection: 0,
                  label: Text(AppLocalizations.of(context)!.monthM),
                  onSelected: (value) => setState(() {
                    newSelectedMonth = value!;
                  }),
                ),
                DropdownMenu(
                  width: 96,
                  dropdownMenuEntries: List.generate(
                      99,
                      (index) => DropdownMenuEntry(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size.fromWidth(96),
                              ),
                            ),
                            value: index,
                            label: index.toString(),
                          ),
                      growable: false),
                  initialSelection: 0,
                  label: Text(AppLocalizations.of(context)!.dayM),
                  onSelected: (value) => setState(() {
                    newSelectedDay = value!;
                  }),
                ),
              ],
            ),

            //ADDIZIONE
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              shrinkWrap: true,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.adding,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      DateFormat('EEEE', Localizations.localeOf(context).languageCode)
                          .format(DateTime(
                          fromDate.year + newSelectedYear,
                          fromDate.month + newSelectedMonth,
                          fromDate.day + newSelectedDay)),
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      DateFormat('d MMM y', Localizations.localeOf(context).languageCode)
                          .format(DateTime(
                          fromDate.year + newSelectedYear,
                          fromDate.month + newSelectedMonth,
                          fromDate.day + newSelectedDay)),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                ),

                //SOTTRAZIONE
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppLocalizations.of(context)!.subtracting,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      DateFormat('EEEE', Localizations.localeOf(context).languageCode)
                          .format(DateTime(
                          fromDate.year - newSelectedYear,
                          fromDate.month - newSelectedMonth,
                          fromDate.day - newSelectedDay)),
                      style: const TextStyle(fontSize: 24),
                    ),
                    Text(
                      DateFormat('d MMM y', Localizations.localeOf(context).languageCode)
                          .format(DateTime(
                          fromDate.year - newSelectedYear,
                          fromDate.month - newSelectedMonth,
                          fromDate.day - newSelectedDay)),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
