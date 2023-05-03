import 'package:flutter/material.dart';
import 'package:urtask/enums/repeat_duration_enum.dart';
import 'package:urtask/enums/repeat_type_enum.dart';

class RepeatEventView extends StatefulWidget {
  final RepeatType repeatType;
  final RepeatDuration repeatDuration;

  const RepeatEventView({
    super.key,
    required this.repeatType,
    required this.repeatDuration,
  });

  @override
  State<RepeatEventView> createState() => _RepeatEventViewState();
}

class _RepeatEventViewState extends State<RepeatEventView> {
  RepeatType? selectedType;
  RepeatDuration? selectedDuration;

  @override
  void initState() {
    selectedType = widget.repeatType;
    selectedDuration = widget.repeatDuration;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          color: Colors.white,
          onPressed: () {
            Navigator.of(context).pop([selectedType, selectedDuration]);
          },
        ),
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
                });
              },
            ),

            // Per Day
            RadioListTile(
              title: const Text("Every day"),
              value: RepeatType.perDay,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            // Per Week
            RadioListTile(
              title: const Text("Every week"),
              value: RepeatType.perWeek,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            // Per Month
            RadioListTile(
              title: const Text("Every month"),
              value: RepeatType.perMonth,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
                });
              },
            ),

            // Per Year
            RadioListTile(
              title: const Text("Every year"),
              value: RepeatType.perYear,
              groupValue: selectedType,
              onChanged: (value) {
                setState(() {
                  selectedType = value;
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
    );
  }
}
