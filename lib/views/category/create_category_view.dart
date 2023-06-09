import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/dialogs/offline_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/utilities/dialogs/colors_dialog.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  late final ColorController _colorService;
  late final CategoryController _categoryService;
  late final TextEditingController _eventCategoryTitle;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  String colorId = "color1";
  String colorName = "Tomato";
  String colorHex = "#D50000";
  late final FocusNode eventTitleFocus;
  bool eventIsEdited = false;

  @override
  void initState() {
    initConnectivity();
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    _colorService = ColorController();
    _categoryService = CategoryController();
    _eventCategoryTitle = TextEditingController();
    eventTitleFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _eventCategoryTitle.dispose();
    _connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text("Create Event Category",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () => _shouldDiscard(),
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
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    onChanged: (value) {
                      eventIsEdited = true;
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 6),
                        child: Text("Color:", style: TextStyle(fontSize: 20)),
                      ),
                      SizedBox(
                          width: 200,
                          child: ListTile(
                            title: Center(
                              child: Text(
                                colorName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            tileColor: HexColor.fromHex(colorHex),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            visualDensity: const VisualDensity(vertical: -4),
                            onTap: () => _pickColor(),
                          ))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 1.0)),
        ),
        child: TextButton(
          onPressed: () => _save(),
          child: const Text("Save", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
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

  Future<bool> _shouldDiscard() async {
    setState(() {
      eventTitleFocus.unfocus();
    });
    if (eventIsEdited || _eventCategoryTitle.text.isNotEmpty) {
      final shouldDiscard = await showDiscardDialog(
        context,
        "Are you sure you want to discard this event category?",
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
  }

  void _pickColor() async {
    setState(() {
      eventTitleFocus.unfocus();
      eventIsEdited = true;
    });
    final colorDetail = await showColorsDialog(context, _colorService);
    if (colorDetail.isNotEmpty) {
      setState(() {
        colorId = colorDetail[0];
        colorName = colorDetail[1];
        colorHex = colorDetail[2];
      });
    }
  }

  void _save() async {
    if (_connectionStatus == ConnectivityResult.none) {
      showOfflineDialog(
        context: context,
        text: "Please turn on your Internet connection",
      );
    } else {
      showLoadingDialog(context: context, text: "Saving");
      await _categoryService.create(
          colorId: colorId,
          name: _eventCategoryTitle.text.isNotEmpty
              ? _eventCategoryTitle.text
              : "My Category");
      if (mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
      }
    }
  }
}
