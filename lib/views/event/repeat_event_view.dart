import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/color.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';
import 'package:urtask/helpers/datetime/datetime_helper.dart';
import 'package:urtask/views/date/date_scroll_view.dart';

class RepeatEventView extends StatefulWidget {
  final RepeatType type;
  final RepeatDuration duration;
  final int typeAmount;
  final int? durationAmount;
  final DateTime? durationDate;
  final DateTime start;

  const RepeatEventView({
    super.key,
    required this.type,
    required this.duration,
    required this.typeAmount,
    this.durationAmount,
    this.durationDate,
    required this.start,
  });

  @override
  State<RepeatEventView> createState() => _RepeatEventViewState();
}

class _RepeatEventViewState extends State<RepeatEventView> {
  RepeatType? selectedType;
  RepeatDuration? selectedDuration;
  late int selectedTypeAmount;
  late int? selectedDurationAmount;
  late DateTime? selectedDurationDate;

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

  // Specific Number
  late final TextEditingController specificNumberAmount;
  late final FocusNode specificNumberFocus;
  bool specificNumberFlag = true;
  bool specificNumberPlural = false;

  // Until
  late FixedExtentScrollController untilDay;
  late FixedExtentScrollController untilMonth;
  late FixedExtentScrollController untilYear;
  late DateTime selectedUntilDateTime;
  late int selectedUntilDay;
  late int selectedUntilMonth;
  late int selectedUntilYear;
  bool untilDateScrollToggle = false;
  bool untilFlag = false;

  @override
  void initState() {
    selectedType = widget.type;
    selectedDuration = widget.duration;
    selectedTypeAmount = widget.typeAmount;
    selectedDurationAmount = widget.durationAmount;
    selectedDurationDate = widget.durationDate;

    final eventStart = widget.start;
    final untilInitialLimit = DateTime(
      eventStart.year,
      eventStart.month,
      eventStart.day,
    ).add(const Duration(days: 1));
    selectedUntilDay = untilInitialLimit.day - 1;
    selectedUntilMonth = untilInitialLimit.month - 1;
    selectedUntilYear = untilInitialLimit.year;

    if (selectedType == RepeatType.perDay) {
      perDayAmount = TextEditingController(text: selectedTypeAmount.toString());
      perDayFlag = true;
    } else {
      perDayAmount = TextEditingController(text: "1");
    }
    if (selectedType == RepeatType.perWeek) {
      perWeekAmount =
          TextEditingController(text: selectedTypeAmount.toString());
      perWeekFlag = true;
    } else {
      perWeekAmount = TextEditingController(text: "1");
    }
    if (selectedType == RepeatType.perMonth) {
      perMonthAmount =
          TextEditingController(text: selectedTypeAmount.toString());
      perMonthFlag = true;
    } else {
      perMonthAmount = TextEditingController(text: "1");
    }
    if (selectedType == RepeatType.perYear) {
      perYearAmount =
          TextEditingController(text: selectedTypeAmount.toString());
      perYearFlag = true;
    } else {
      perYearAmount = TextEditingController(text: "1");
    }
    if (selectedDuration == RepeatDuration.specificNumber &&
        selectedDurationAmount != null) {
      specificNumberAmount =
          TextEditingController(text: selectedDurationAmount.toString());
    } else {
      specificNumberAmount = TextEditingController(text: "1");
    }
    perDayFocus = FocusNode();
    perWeekFocus = FocusNode();
    perMonthFocus = FocusNode();
    perYearFocus = FocusNode();
    specificNumberFocus = FocusNode();
    if (selectedDuration == RepeatDuration.until &&
        selectedDurationDate != null) {
      selectedUntilDateTime = selectedDurationDate!;
      selectedUntilDay = selectedUntilDateTime.day - 1;
      selectedUntilMonth = selectedUntilDateTime.month - 1;
      selectedUntilYear = selectedUntilDateTime.year;
      untilFlag = true;
      specificNumberFlag = false;
    } else {
      selectedUntilDateTime = DateTime(
        selectedUntilYear,
        selectedUntilMonth + 1,
        selectedUntilDay + 1,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    perDayAmount.dispose();
    perDayFocus.dispose();
    perWeekAmount.dispose();
    perWeekFocus.dispose();
    perMonthAmount.dispose();
    perMonthFocus.dispose();
    perYearAmount.dispose();
    perYearFocus.dispose();
    specificNumberAmount.dispose();
    specificNumberFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (selectedType == RepeatType.noRepeat) {
          setState(() {
            selectedDuration = RepeatDuration.values.elementAt(0);
          });
          Navigator.of(context).pop([selectedType, selectedDuration, 0, null]);
          return true;
        } else {
          setState(() {
            if (selectedType == RepeatType.perDay) {
              if (perDayAmount.text == "") {
                perDayAmount.text = "1";
              }
              selectedTypeAmount = int.parse(perDayAmount.text);
            } else if (selectedType == RepeatType.perWeek) {
              if (perWeekAmount.text == "") {
                perWeekAmount.text = "1";
              }
              selectedTypeAmount = int.parse(perWeekAmount.text);
            } else if (selectedType == RepeatType.perMonth) {
              if (perMonthAmount.text == "") {
                perMonthAmount.text = "1";
              }
              selectedTypeAmount = int.parse(perMonthAmount.text);
            } else if (selectedType == RepeatType.perYear) {
              if (perYearAmount.text == "") {
                perYearAmount.text = "1";
              }
              selectedTypeAmount = int.parse(perYearAmount.text);
            }
          });
          if (selectedDuration == RepeatDuration.specificNumber) {
            if (specificNumberAmount.text == "") {
              specificNumberAmount.text = "1";
            }
            selectedDurationAmount = int.parse(specificNumberAmount.text);
            Navigator.of(context).pop([
              selectedType,
              selectedDuration,
              selectedTypeAmount,
              selectedDurationAmount
            ]);
          } else if (selectedDuration == RepeatDuration.until) {
            if (untilDateScrollToggle == true) {
              _untilDateScrollOff();
            }
            selectedDurationDate = selectedUntilDateTime;
            Navigator.of(context).pop([
              selectedType,
              selectedDuration,
              selectedTypeAmount,
              selectedDurationDate
            ]);
          }
        }
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
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // No Repeat
              RadioListTile(
                title: const Text(
                  "Don't repeat",
                  style: TextStyle(fontSize: 18),
                ),
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
                    if (specificNumberAmount.text == "") {
                      specificNumberAmount.text = "1";
                    }
                    if (untilDateScrollToggle == true) {
                      _untilDateScrollOff();
                      untilDateScrollToggle = false;
                    }
                  });
                },
              ),

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),

              // Per Day
              RadioListTile(
                title: Row(
                  children: [
                    if (perDayFlag == false) ...[
                      const Text(
                        "Everyday",
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                    if (perDayFlag == true) ...[
                      const Text(
                        "Every ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 40,
                        child: TextFormField(
                          controller: perDayAmount,
                          focusNode: perDayFocus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
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
                        const Text(
                          " days",
                          style: TextStyle(fontSize: 18),
                        )
                      else
                        const Text(
                          " day",
                          style: TextStyle(fontSize: 18),
                        ),
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

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),

              // Per Week
              RadioListTile(
                title: Row(
                  children: [
                    if (perWeekFlag == false) ...[
                      const Text(
                        "Every week",
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                    if (perWeekFlag == true) ...[
                      const Text(
                        "Every ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perWeekAmount,
                          focusNode: perWeekFocus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
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
                        const Text(
                          " weeks",
                          style: TextStyle(fontSize: 18),
                        )
                      else
                        const Text(
                          " week",
                          style: TextStyle(fontSize: 18),
                        ),
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

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),

              // Per Month
              RadioListTile(
                title: Row(
                  children: [
                    if (perMonthFlag == false) ...[
                      const Text(
                        "Every month",
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                    if (perMonthFlag == true) ...[
                      const Text(
                        "Every ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perMonthAmount,
                          focusNode: perMonthFocus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
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
                        const Text(
                          " months",
                          style: TextStyle(fontSize: 18),
                        )
                      else
                        const Text(
                          " month",
                          style: TextStyle(fontSize: 18),
                        ),
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

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),

              // Per Year
              RadioListTile(
                title: Row(
                  children: [
                    if (perYearFlag == false) ...[
                      const Text(
                        "Every year",
                        style: TextStyle(fontSize: 18),
                      )
                    ],
                    if (perYearFlag == true) ...[
                      const Text(
                        "Every ",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(
                        width: 35,
                        child: TextFormField(
                          controller: perYearAmount,
                          focusNode: perYearFocus,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                          ),
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
                        const Text(
                          " years",
                          style: TextStyle(fontSize: 18),
                        )
                      else
                        const Text(
                          " year",
                          style: TextStyle(fontSize: 18),
                        ),
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

              const Divider(
                indent: 10,
                endIndent: 10,
                height: 1,
                thickness: 1,
                color: Color.fromARGB(255, 125, 121, 121),
              ),

              // Duration
              if (selectedType != RepeatType.noRepeat) ...[
                const SizedBox(height: 50),
                Row(
                  children: const [
                    SizedBox(width: 20),
                    Text(
                      "Duration",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // Specific Number
                RadioListTile(
                  title: Row(
                    children: [
                      if (specificNumberFlag == false) ...[
                        const Text(
                          "Specific number of times",
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                      if (specificNumberFlag == true) ...[
                        SizedBox(
                          width: 35,
                          child: TextFormField(
                            controller: specificNumberAmount,
                            focusNode: specificNumberFocus,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                            ),
                            onChanged: (value) {
                              setState(() {
                                specificNumberPlural =
                                    value.isEmpty || int.parse(value) <= 1
                                        ? false
                                        : true;
                              });
                              if (value.isNotEmpty) {
                                if (int.parse(value) <= 0) {
                                  setState(() {
                                    specificNumberAmount.text = "1";
                                    specificNumberAmount.selection =
                                        const TextSelection.collapsed(
                                            offset: 1);
                                    specificNumberPlural = false;
                                  });
                                }
                                if (int.parse(value) > 100) {
                                  setState(() {
                                    specificNumberAmount.text = "100";
                                    specificNumberAmount.selection =
                                        const TextSelection.collapsed(
                                            offset: 3);
                                    specificNumberPlural = true;
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
                        if (specificNumberPlural)
                          const Text(
                            " times",
                            style: TextStyle(fontSize: 18),
                          )
                        else
                          const Text(
                            " time",
                            style: TextStyle(fontSize: 18),
                          ),
                      ],
                    ],
                  ),
                  value: RepeatDuration.specificNumber,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value;
                      specificNumberFlag = true;
                      untilFlag = false;
                      if (untilDateScrollToggle == true) {
                        _untilDateScrollOff();
                      }
                      if (specificNumberAmount.text == "") {
                        specificNumberAmount.text = "1";
                      }
                    });
                  },
                ),

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),

                // Until
                RadioListTile(
                  title: Row(
                    children: [
                      const Text(
                        "Until",
                        style: TextStyle(fontSize: 18),
                      ),
                      if (untilFlag == true) ...[
                        if (untilDateScrollToggle == false) ...[
                          TextButton(
                            onPressed: () {
                              _untilDateScrollOn();
                            },
                            child: Text(
                              DateTimeHelper.dateToString(
                                month: selectedUntilDateTime.month - 1,
                                day: selectedUntilDateTime.day - 1,
                                year: selectedUntilDateTime.year,
                              ),
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                        if (untilDateScrollToggle == true) ...[
                          SizedBox(
                            width: 115,
                            child: TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    const Color.fromARGB(255, 234, 220, 220),
                              ),
                              onPressed: () {
                                _untilDateScrollOff();
                              },
                              child: const Text(
                                ". . .",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ]
                    ],
                  ),
                  value: RepeatDuration.until,
                  groupValue: selectedDuration,
                  onChanged: (value) {
                    setState(() {
                      selectedDuration = value;
                      untilFlag = true;
                      specificNumberFlag = false;
                    });
                  },
                ),

                if (untilDateScrollToggle == true) ...[
                  // Date Scroll
                  DateScrollView(
                    day: untilDay,
                    month: untilMonth,
                    year: untilYear,
                  ),
                  const SizedBox(height: 20)
                ],

                const Divider(
                  indent: 10,
                  endIndent: 10,
                  height: 1,
                  thickness: 1,
                  color: Color.fromARGB(255, 125, 121, 121),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _untilDateScrollOn() {
    setState(() {
      untilDay = FixedExtentScrollController(
        initialItem: selectedUntilDay,
      );
      untilMonth = FixedExtentScrollController(
        initialItem: selectedUntilMonth,
      );
      untilYear = FixedExtentScrollController(
        initialItem: selectedUntilYear % DateTime.now().year,
      );
    });
    setState(() {
      untilDateScrollToggle = true;
    });
  }

  void _untilDateScrollOff() {
    final eventStart = widget.start;
    final untilMinLimit = DateTime(
      eventStart.year,
      eventStart.month,
      eventStart.day + 1,
    );

    setState(() {
      selectedUntilDay = untilDay.selectedItem;
      selectedUntilMonth = untilMonth.selectedItem % 12;
      selectedUntilYear = DateTime.now().year + untilYear.selectedItem;

      if (selectedUntilMonth == 1) {
        if ((selectedUntilYear % 4 == 0) &&
            (selectedUntilYear % 100 != 0 || selectedUntilYear % 400 == 0)) {
          selectedUntilDay %= 29;
        } else {
          selectedUntilDay %= 28;
        }
      } else if (selectedUntilMonth.isEven && selectedUntilMonth <= 6 ||
          selectedUntilMonth == 7 ||
          selectedUntilMonth == 9 ||
          selectedUntilMonth == 11) {
        selectedUntilDay %= 31;
      } else {
        selectedUntilDay %= 30;
      }
    });
    setState(() {
      untilDateScrollToggle = false;
      selectedUntilDateTime = DateTime(
        selectedUntilYear,
        selectedUntilMonth + 1,
        selectedUntilDay + 1,
      );
      if (selectedUntilDateTime.isBefore(untilMinLimit)) {
        selectedUntilYear = untilMinLimit.year;
        selectedUntilMonth = untilMinLimit.month - 1;
        selectedUntilDay = untilMinLimit.day - 1;
        selectedUntilDateTime = DateTime(
          selectedUntilYear,
          selectedUntilMonth + 1,
          selectedUntilDay + 1,
        );
      }
    });
  }
}
