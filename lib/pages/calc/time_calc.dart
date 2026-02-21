import 'package:flutter/material.dart';
import 'package:lapiscalc/l10n/app_localizations.dart';

class TimeCalc extends StatefulWidget {
  const TimeCalc({super.key});
  static String pageTitle = "Time";

  @override
  State<TimeCalc> createState() => _TimeCalcState();
}

class _TimeCalcState extends State<TimeCalc>
    with AutomaticKeepAliveClientMixin<TimeCalc> {
  final List<Widget> _pages = [const BuildTimeDiff(), const AddSubTime()];
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
            text: AppLocalizations.of(context)!.timedifference
          ),
          Tab(
            text: AppLocalizations.of(context)!.addsubtracttime
          )
        ]),
        body: SafeArea(child: TabBarView(children: _pages)),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class BuildTimeDiff extends StatefulWidget {
  const BuildTimeDiff({super.key});

  @override
  State<BuildTimeDiff> createState() => _BuildTimeDiffState();
}

class _BuildTimeDiffState extends State<BuildTimeDiff>
    with AutomaticKeepAliveClientMixin<BuildTimeDiff> {
  TimeOfDay selectedTime1 = TimeOfDay.now();
  TimeOfDay selectedTime2 = TimeOfDay.now();

  Future<void> _selectTime1(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime1,
    );
    if (picked != null && picked != selectedTime1) {
      setState(() {
        selectedTime1 = picked;
      });
    }
  }

  Future<void> _selectTime2(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime2,
    );
    if (picked != null && picked != selectedTime2) {
      setState(() {
        selectedTime2 = picked;
      });
    }
  }

  int timeDiffMinutes(TimeOfDay t1, TimeOfDay t2) {
    int m1 = t1.hour * 60 + t1.minute;
    int m2 = t2.hour * 60 + t2.minute;
    int diff = m2 - m1;
    if (diff < 0) {
      diff += 1440; // avvolgi attorno alla mezzanotte
    }
    return diff;
  }

  String formatMinutes(int totalMinutes) {
    int hours = totalMinutes ~/ 60;
    int minutes = totalMinutes % 60;

    String result = '';
    if (hours > 0) {
      result += '${hours.toString()} ${hours == 1 ? (AppLocalizations.of(context)!.hour) : (AppLocalizations.of(context)!.hours)}';
    }
    if (minutes > 0) {
      result += '${result.isNotEmpty ? ', ' : ''}${minutes.toString()} ${minutes == 1 ? (AppLocalizations.of(context)!.minute) : (AppLocalizations.of(context)!.minutes)}';
    }

    if (hours == 0 && minutes == 0) {
      return "0 ${AppLocalizations.of(context)!.minutes}";
    }

    return result;
  }

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
                    const Icon(Icons.access_time_outlined),
                    const SizedBox(width: 8,),
                    Text(selectedTime1.format(context)),
                ],
              )),
              onTap: () => _selectTime1(context),
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
                    const Icon(Icons.access_time_outlined),
                    const SizedBox(width: 8,),
                    Text(selectedTime2.format(context)),
                ],
              )),
              onTap: () => _selectTime2(context),
            ),
            const SizedBox(
              height: 36,
            ),
            Text(AppLocalizations.of(context)!.difference, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(
              height: 8,
            ),
            timeDiffMinutes(selectedTime1, selectedTime2) == 0
                ? Text(
                    formatMinutes(0),
                    style: const TextStyle(fontSize: 36),
                  )
                : Text(
                    formatMinutes(
                        timeDiffMinutes(selectedTime1, selectedTime2)),
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

class AddSubTime extends StatefulWidget {
  const AddSubTime({super.key});

  @override
  State<AddSubTime> createState() => _AddSubTimeState();
}

class _AddSubTimeState extends State<AddSubTime>
    with AutomaticKeepAliveClientMixin<AddSubTime> {
  TimeOfDay fromTime = TimeOfDay.now();
  int newSelectedHour = 0;
  int newSelectedMinute = 0;

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: fromTime,
    );
    if (picked != null && picked != fromTime) {
      setState(() {
        fromTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Add logic
    int totalMinAdd = fromTime.hour * 60 + fromTime.minute + (newSelectedHour * 60) + newSelectedMinute;
    int addH = (totalMinAdd ~/ 60) % 24;
    int addM = totalMinAdd % 60;
    TimeOfDay addedTime = TimeOfDay(hour: addH, minute: addM);

    // Subtract logic
    int totalMinSub = fromTime.hour * 60 + fromTime.minute - (newSelectedHour * 60) - newSelectedMinute;
    int tempSub = totalMinSub;
    while (tempSub < 0) {
      tempSub += 1440;
    }
    int subH = (tempSub ~/ 60) % 24;
    int subM = tempSub % 60;
    TimeOfDay subbedTime = TimeOfDay(hour: subH, minute: subM);

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
                   const Icon(Icons.access_time_outlined),
                   const SizedBox(width: 8,),
                   Text(fromTime.format(context)),
                ],
              )),
              onTap: () => _selectTime(context),
            ),
            const SizedBox(
              height: 36,
            ),
            GridView(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                DropdownMenu(
                  width: 140,
                  dropdownMenuEntries: List.generate(
                      100,
                      (index) => DropdownMenuEntry(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size.fromWidth(140),
                              ),
                            ),
                            value: index,
                            label: index.toString(),
                          ),
                      growable: false),
                  initialSelection: 0,
                  label: Text(AppLocalizations.of(context)!.hourM),
                  onSelected: (value) => setState(() {
                    newSelectedHour = value!;
                  }),
                ),
                DropdownMenu(
                  width: 140,
                  dropdownMenuEntries: List.generate(
                      60,
                      (index) => DropdownMenuEntry(
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all(
                                const Size.fromWidth(140),
                              ),
                            ),
                            value: index,
                            label: index.toString(),
                          ),
                      growable: false),
                  initialSelection: 0,
                  label: Text(AppLocalizations.of(context)!.minuteM),
                  onSelected: (value) => setState(() {
                    newSelectedMinute = value!;
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
                    const SizedBox(height: 8,),
                    Text(
                      addedTime.format(context),
                      style: const TextStyle(fontSize: 36),
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
                    const SizedBox(height: 8,),
                    Text(
                      subbedTime.format(context),
                      style: const TextStyle(fontSize: 36),
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
