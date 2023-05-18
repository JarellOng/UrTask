import 'package:flutter/material.dart';
import 'package:urtask/views/notification/custom_notification_amount_view.dart';
import 'package:urtask/views/notification/custom_notification_uot.dart';

class CustomNotificationScrollView extends StatefulWidget {
  final FixedExtentScrollController amount;
  final FixedExtentScrollController uot;

  const CustomNotificationScrollView({
    super.key,
    required this.amount,
    required this.uot,
  });

  @override
  State<CustomNotificationScrollView> createState() =>
      _CustomNotificationScrollViewState();
}

class _CustomNotificationScrollViewState
    extends State<CustomNotificationScrollView> {
  late int selectedAmount;
  late int selectedUot;
  late int amountLimit;

  @override
  void initState() {
    selectedAmount = widget.amount.initialItem;
    selectedUot = widget.uot.initialItem;
    if (selectedUot == 0) {
      amountLimit = 61;
    } else if (selectedUot == 1) {
      amountLimit = 25;
    } else if (selectedUot == 2) {
      amountLimit = 366;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Amount
        SizedBox(
          height: 105,
          width: 100,
          child: ListWheelScrollView.useDelegate(
            controller: widget.amount,
            onSelectedItemChanged: (value) {
              setState(() {
                selectedAmount = value;
              });
            },
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildLoopingListDelegate(
              children: List<Widget>.generate(
                amountLimit,
                (index) {
                  if (selectedAmount == index) {
                    return CustomNotificationAmountView(
                      amount: index,
                      color: Colors.black,
                    );
                  }
                  return CustomNotificationAmountView(amount: index);
                },
              ),
            ),
          ),
        ),

        // Unit of Time
        SizedBox(
          height: 105,
          width: 120,
          child: ListWheelScrollView.useDelegate(
            controller: widget.uot,
            onSelectedItemChanged: (value) => setState(() {
              selectedUot = value;
              if (selectedUot == 0) {
                amountLimit = 61;
                if (amountLimit <= selectedAmount) {
                  widget.amount.jumpToItem(60);
                } else {
                  widget.amount.jumpToItem(selectedAmount);
                }
              } else if (selectedUot == 1) {
                amountLimit = 25;
                if (amountLimit <= selectedAmount) {
                  widget.amount.jumpToItem(24);
                } else {
                  widget.amount.jumpToItem(selectedAmount);
                }
              } else if (selectedUot == 2) {
                amountLimit = 366;
                widget.amount.jumpToItem(selectedAmount);
              }
            }),
            itemExtent: 35,
            perspective: 0.0001,
            physics: const FixedExtentScrollPhysics(),
            childDelegate: ListWheelChildListDelegate(
              children: List<Widget>.generate(
                3,
                (index) {
                  if (selectedUot == index) {
                    return CustomNotificationUotView(
                      uot: index,
                      amount: selectedAmount,
                      color: Colors.black,
                    );
                  }
                  return CustomNotificationUotView(uot: index);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}
