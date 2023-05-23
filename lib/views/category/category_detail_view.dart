import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/utilities/dialogs/delete_dialog.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
import 'package:urtask/utilities/dialogs/event_group_delete_dialog.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/dialogs/offline_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/category/categories_view.dart';
import 'package:urtask/views/color_view.dart';

class categoryDetailView extends StatefulWidget {
  final String categoryId;
  const categoryDetailView({
    super.key,
    required this.categoryId,
  });

  @override
  State<categoryDetailView> createState() => _categoryDetailViewState();
}

class _categoryDetailViewState extends State<categoryDetailView> {
  late final ColorController _colorService;
  late final EventController _eventService;
  late final CategoryController _categoryService;
  late final TextEditingController _eventCategoryTitle;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String _categoryId = "";
  String colorId = "color1";
  String colorName = "Tomato";
  String colorHex = "#D50000";
  final userId = AuthService.firebase().currentUser!.id;
  late final FocusNode eventTitleFocus;
  bool eventIsEdited = false;

  var _eventGroupId;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _colorService = ColorController();
    _eventService = EventController();
    _categoryService = CategoryController();
    _eventCategoryTitle = TextEditingController();
    eventTitleFocus = FocusNode();
    setup();
    super.initState();
  }

  @override
  void dispose() {
    _eventCategoryTitle.dispose();
    super.dispose();
  }

  Future<void> initConnectivity() async {
    late ConnectivityResult result;

    try {
      result = await _connectivity.checkConnectivity();
    } on PlatformException {
      return;
    }

    if (!mounted) {
      return Future.value(null);
    }

    return _updateConnectionStatus(result);
  }

  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    setState(() {
      _connectionStatus = result;
    });
  }

  void setup() async {
    final category = await _categoryService
        .get(id: widget.categoryId)
        .then((value) => value);
    final color =
        await _colorService.get(id: category.colorId).then((value) => value);
    setState(() {
      _categoryId = category.id;
      _eventCategoryTitle.text = category.name;
      colorId = color.id;
      colorName = color.name;
      colorHex = color.hex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event Category",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          setState(() {
            eventTitleFocus.unfocus();
          });
          if (eventIsEdited) {
            final shouldDiscard = await showDiscardDialog(
              context,
              "Are you sure you want to discard this event?",
            );
            if (shouldDiscard) {
              if (mounted) {
                Navigator.of(context).pop();
                return true;
              }
            }
            return false;
          }
          return true;
        },
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _eventCategoryTitle,
                      focusNode: eventTitleFocus,
                      enableSuggestions: false,
                      autocorrect: false,
                      maxLines: 2,
                      decoration: const InputDecoration(
                          isDense: true,
                          hintText: "Event Category Name",
                          hintStyle: TextStyle(fontSize: 18)),
                      style: TextStyle(fontSize: 18),
                      onChanged: (value) {
                        eventIsEdited = true;
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Text("Color:", style: TextStyle(fontSize: 20)),
                        ),
                        Container(
                            width: 200,
                            child: ListTile(
                              title: Center(
                                child: Text(colorName,
                                    style: TextStyle(
                                        fontSize: 20, color: Colors.white)),
                              ),
                              tileColor: HexColor.fromHex(colorHex),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20)),
                              visualDensity: VisualDensity(vertical: -4),
                              onTap: () async {
                                setState(() {
                                  eventTitleFocus.unfocus();
                                  eventIsEdited = true;
                                });
                                final colorDetail = await showColorsDialog(
                                    context, _colorService);
                                if (colorDetail.isNotEmpty) {
                                  setState(() {
                                    colorId = colorDetail[0];
                                    colorName = colorDetail[1];
                                    colorHex = colorDetail[2];
                                  });
                                }
                              },
                            ))
                      ],
                    ),
                  ],
                )),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.black, width: 1.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // DELETE BUTTON
            TextButton(
              onPressed: () async {
                if (_connectionStatus == ConnectivityResult.none) {
                  showOfflineDialog(
                    context: context,
                    text: "Please turn on your Internet connection",
                  );
                } else {
                  final shouldDelete = await showDeleteDialog(
                    context,
                    "Are you sure you want to delete this event?",
                  );
                  if (shouldDelete) {
                    showLoadingDialog(context: context, text: "Deleting");
                    if (_eventGroupId != null && mounted) {
                      final shouldDeleteAllRepeatedEvents =
                          await showEventGroupDeleteDialog(context);
                      if (shouldDeleteAllRepeatedEvents == true) {
                        await _eventService.bulkDeleteByCategoryId(
                            id: _eventGroupId!);
                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      } else if (shouldDeleteAllRepeatedEvents == false) {
                        await _categoryService.delete(id: _categoryId);
                        if (mounted) {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        }
                      }
                    } else {
                      await _categoryService.delete(id: _categoryId);
                      if (mounted) {
                        Navigator.of(context).pop();
                        Navigator.of(context).pop();
                      }
                    }
                  }
                }
              },
              child: const Text("Delete", style: TextStyle(fontSize: 18)),
            ),

            // SAVE BUTTON
            TextButton(
              onPressed: () async {
                if (_connectionStatus == ConnectivityResult.none) {
                  showOfflineDialog(
                    context: context,
                    text: "Please turn on your Internet connection",
                  );
                } else {
                  showLoadingDialog(context: context, text: "Saving");
                  // Update Categories
                  await _categoryService.update(
                      id: _categoryId,
                      colorId: colorId,
                      name: _eventCategoryTitle.text.isNotEmpty
                          ? _eventCategoryTitle.text
                          : "My Event");
                  // Update Notification
                  if (mounted) {
                    Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryView(),
              ),
            );
                  }
                }
              },
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
