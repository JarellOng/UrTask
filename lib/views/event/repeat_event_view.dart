import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';

class RepeatEventView extends StatefulWidget {
  final RepeatType type;
  final RepeatDuration duration;

  const RepeatEventView({
    super.key,
    required this.type,
    required this.duration,
  });

  @override
  State<RepeatEventView> createState() => _RepeatEventViewState();
}

class _RepeatEventViewState extends State<RepeatEventView> {
  RepeatType? selectedType;
  RepeatDuration? selectedDuration;

  // Per Day
  late final TextEditingController perDayAmount;
  late final FocusNode perDayFocus;
  bool perDayFlag = false;
  bool perDayPlural = false;

  // Per Week
  late final TextEditingController perWeekAmount;
  late final FocusNode perWeekFocus;
  bool perWeekFlag = false;
  bool perWeekPlural = false;

  // Per Month
  late final TextEditingController perMonthAmount;
  late final FocusNode perMonthFocus;
  bool perMonthFlag = false;
  bool perMonthPlural = false;

  // Per Year
  late final TextEditingController perYearAmount;
  late final FocusNode perYearFocus;
  bool perYearFlag = false;
  bool perYearPlural = false;

  @override
  void initState() {
    selectedType = widget.type;
    selectedDuration = widget.duration;
    perDayAmount = TextEditingController(text: "1");
    perWeekAmount = TextEditingController(text: "1");
    perMonthAmount = TextEditingController(text: "1");
    perYearAmount = TextEditingController(text: "1");
    perDayFocus = FocusNode();
    perWeekFocus = FocusNode();
    perMonthFocus = FocusNode();
    perYearFocus = FocusNode();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedType == RepeatType.noRepeat) {
          setState(() {
            selectedDuration = RepeatDuration.values.elementAt(0);
          });
          Navigator.of(context).pop([selectedType, selectedDuration]);
          return true;
        }
        Navigator.of(context).pop([selectedType, selectedDuration]);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: const BackButton(color: Colors.white),
          title: const Text(
            "Repeat Event",
            style: TextStyle(color: Colors.white),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // No Repeat
              RadioListTile(
                title: const Text("Don't repeat"),
                value: RepeatType.noRepeat,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    perDayFlag = false;
                    perDayFocus.unfocus();
                    perWeekFlag = false;
                    perWeekFocus.unfocus();
                    perMonthFlag = false;
                    perMonthFocus.unfocus();
                    perYearFlag = false;
                    perYearFocus.unfocus();
                  });
                },
              ),

              // Per Day
              RadioListTile(
                title: Row(
                  children: [
                    if (perDayFlag == false) ...[const Text("Everyday")],
                    if (perDayFlag == true) ...[
                      const Text("Every "),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perDayAmount,
                          focusNode: perDayFocus,
                          onChanged: (value) {
                            setState(() {
                              perDayPlural =
                                  value.isEmpty || int.parse(value) <= 1
                                      ? false
                                      : true;
                            });
                            if (value.isNotEmpty) {
                              if (int.parse(value) <= 0) {
                                setState(() {
                                  perDayAmount.text = "1";
                                  perDayAmount.selection =
                                      const TextSelection.collapsed(offset: 1);
                                  perDayPlural = false;
                                });
                              }
                              if (int.parse(value) > 365) {
                                setState(() {
                                  perDayAmount.text = "365";
                                  perDayAmount.selection =
                                      const TextSelection.collapsed(offset: 3);
                                  perDayPlural = true;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          autocorrect: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                        ),
                      ),
                      if (perDayPlural)
                        const Text(" days")
                      else
                        const Text(" day"),
                    ],
                  ],
                ),
                value: RepeatType.perDay,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    perDayFlag = true;
                    perWeekFlag = false;
                    perWeekFocus.unfocus();
                    perMonthFlag = false;
                    perMonthFocus.unfocus();
                    perYearFlag = false;
                    perYearFocus.unfocus();
                    if (perDayAmount.text == "") {
                      perDayAmount.text = "1";
                    }
                  });
                },
              ),

              // Per Week
              RadioListTile(
                title: Row(
                  children: [
                    if (perWeekFlag == false) ...[const Text("Every week")],
                    if (perWeekFlag == true) ...[
                      const Text("Every "),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perWeekAmount,
                          focusNode: perWeekFocus,
                          onChanged: (value) {
                            setState(() {
                              perWeekPlural =
                                  value.isEmpty || int.parse(value) <= 1
                                      ? false
                                      : true;
                            });
                            if (value.isNotEmpty) {
                              if (int.parse(value) <= 0) {
                                setState(() {
                                  perWeekAmount.text = "1";
                                  perWeekAmount.selection =
                                      const TextSelection.collapsed(offset: 1);
                                  perWeekPlural = false;
                                });
                              }
                              if (int.parse(value) > 52) {
                                setState(() {
                                  perWeekAmount.text = "52";
                                  perWeekAmount.selection =
                                      const TextSelection.collapsed(offset: 2);
                                  perWeekPlural = true;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          autocorrect: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                      if (perWeekPlural)
                        const Text(" weeks")
                      else
                        const Text(" week"),
                    ],
                  ],
                ),
                value: RepeatType.perWeek,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    perWeekFlag = true;
                    perDayFlag = false;
                    perDayFocus.unfocus();
                    perMonthFlag = false;
                    perMonthFocus.unfocus();
                    perYearFlag = false;
                    perYearFocus.unfocus();
                    if (perWeekAmount.text == "") {
                      perWeekAmount.text = "1";
                    }
                  });
                },
              ),

              // Per Month
              RadioListTile(
                title: Row(
                  children: [
                    if (perMonthFlag == false) ...[const Text("Every month")],
                    if (perMonthFlag == true) ...[
                      const Text("Every "),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perMonthAmount,
                          focusNode: perMonthFocus,
                          onChanged: (value) {
                            setState(() {
                              perMonthPlural =
                                  value.isEmpty || int.parse(value) <= 1
                                      ? false
                                      : true;
                            });
                            if (value.isNotEmpty) {
                              if (int.parse(value) <= 0) {
                                setState(() {
                                  perMonthAmount.text = "1";
                                  perMonthAmount.selection =
                                      const TextSelection.collapsed(offset: 1);
                                  perMonthPlural = false;
                                });
                              }
                              if (int.parse(value) > 12) {
                                setState(() {
                                  perMonthAmount.text = "12";
                                  perMonthAmount.selection =
                                      const TextSelection.collapsed(offset: 2);
                                  perMonthPlural = true;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          autocorrect: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                      if (perMonthPlural)
                        const Text(" months")
                      else
                        const Text(" month"),
                    ],
                  ],
                ),
                value: RepeatType.perMonth,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    perMonthFlag = true;
                    perDayFlag = false;
                    perDayFocus.unfocus();
                    perWeekFlag = false;
                    perWeekFocus.unfocus();
                    perYearFlag = false;
                    perYearFocus.unfocus();
                    if (perMonthAmount.text == "") {
                      perMonthAmount.text = "1";
                    }
                  });
                },
              ),

              // Per Year
              RadioListTile(
                title: Row(
                  children: [
                    if (perYearFlag == false) ...[const Text("Every year")],
                    if (perYearFlag == true) ...[
                      const Text("Every "),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perYearAmount,
                          focusNode: perYearFocus,
                          onChanged: (value) {
                            setState(() {
                              perYearPlural =
                                  value.isEmpty || int.parse(value) <= 1
                                      ? false
                                      : true;
                            });
                            if (value.isNotEmpty) {
                              if (int.parse(value) <= 0) {
                                setState(() {
                                  perYearAmount.text = "1";
                                  perYearAmount.selection =
                                      const TextSelection.collapsed(offset: 1);
                                  perYearPlural = false;
                                });
                              }
                              if (int.parse(value) > 10) {
                                setState(() {
                                  perYearAmount.text = "10";
                                  perYearAmount.selection =
                                      const TextSelection.collapsed(offset: 2);
                                  perYearPlural = true;
                                });
                              }
                            }
                          },
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          enableSuggestions: false,
                          autocorrect: false,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(2),
                          ],
                        ),
                      ),
                      if (perYearPlural)
                        const Text(" years")
                      else
                        const Text(" year"),
                    ],
                  ],
                ),
                value: RepeatType.perYear,
                groupValue: selectedType,
                onChanged: (value) {
                  setState(() {
                    selectedType = value;
                    perYearFlag = true;
                    perDayFlag = false;
                    perDayFocus.unfocus();
                    perWeekFlag = false;
                    perWeekFocus.unfocus();
                    perMonthFlag = false;
                    perMonthFocus.unfocus();
                    if (perYearAmount.text == "") {
                      perYearAmount.text = "1";
                    }
                  });
                },
              ),

              // Duration
              if (selectedType != RepeatType.noRepeat) ...[
                const SizedBox(height: 50),
                const Text(
                  "Duration",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                // Specific Number
                RadioListTile(
                  title: const Text("Specific number of times"),
                  value: RepeatDuration.specificNumber,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value;
                    });
                  },
                ),

                // Until
                RadioListTile(
                  title: const Text("Until"),
                  value: RepeatDuration.until,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
