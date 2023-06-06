import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/events/events_controller.dart';
import 'package:urtask/utilities/dialogs/delete_dialog.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
import 'package:urtask/utilities/dialogs/loading_dialog.dart';
import 'package:urtask/utilities/dialogs/offline_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/utilities/dialogs/colors_dialog.dart';

class CategoryDetailView extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final String colorId;
  final String colorName;
  final String colorHex;

  const CategoryDetailView({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.colorId,
    required this.colorName,
    required this.colorHex,
  });

  @override
  State<CategoryDetailView> createState() => _CategoryDetailViewState();
}

class _CategoryDetailViewState extends State<CategoryDetailView> {
  late final ColorController _colorService;
  late final EventController _eventService;
  late final CategoryController _categoryService;
  late final TextEditingController _eventCategoryTitle;

  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  late String _categoryId;
  late String colorId;
  late String colorName;
  late String colorHex;
  late final FocusNode eventTitleFocus;
  bool eventIsEdited = false;

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
    _categoryId = widget.categoryId;
    _eventCategoryTitle.text = widget.categoryName;
    colorId = widget.colorId;
    colorName = widget.colorName;
    colorHex = widget.colorHex;
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
        title: const Text(
          "Event Category Detail",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: WillPopScope(
        onWillPop: () => _shouldDiscardChanges(),
        child: Column(
          children: [
            Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    // NAME
                    SizedBox(
                      width: 350,
                      child: TextField(
                        readOnly: _categoryService.isPreset(id: _categoryId),
                        controller: _eventCategoryTitle,
                        focusNode: eventTitleFocus,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: const InputDecoration(
                          hintText: "Event Category Name",
                          hintStyle: TextStyle(fontSize: 18),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        onChanged: (value) {
                          eventIsEdited = true;
                        },
                      ),
                    ),

                    const Divider(
                      indent: 10,
                      endIndent: 10,
                      height: 1,
                      thickness: 1,
                      color: Color.fromARGB(255, 125, 121, 121),
                    ),
                    const SizedBox(height: 20),

                    // COLOR
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
                            enabled:
                                !_categoryService.isPreset(id: _categoryId),
                            title: Center(
                              child: Text(
                                colorName,
                                style: const TextStyle(
                                    fontSize: 20, color: Colors.white),
                              ),
                            ),
                            tileColor: HexColor.fromHex(colorHex),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            visualDensity: const VisualDensity(vertical: -4),
                            onTap: () => _pickColor(),
                          ),
                        )
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
            if (!_categoryService.isPreset(id: _categoryId)) ...[
              // DELETE BUTTON
              TextButton(
                onPressed: () => _shouldDelete(),
                child: const Text("Delete", style: TextStyle(fontSize: 18)),
              ),

              // SAVE BUTTON
              TextButton(
                onPressed: () => _saveChanges(),
                child: const Text("Save", style: TextStyle(fontSize: 18)),
              ),
            ],
          ],
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

  Future<bool> _shouldDiscardChanges() async {
    setState(() {
      eventTitleFocus.unfocus();
    });
    if (eventIsEdited) {
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

  void _shouldDelete() async {
    if (_connectionStatus == ConnectivityResult.none) {
      showOfflineDialog(
        context: context,
        text: "Please turn on your Internet connection",
      );
    } else {
      final shouldDelete = await showDeleteDialog(
        context,
        "Are you sure you want to delete this event category?",
      );
      if (shouldDelete) {
        showLoadingDialog(context: context, text: "Deleting");
        await _categoryService.delete(id: _categoryId);
        await _eventService.bulkDeleteByCategoryId(id: _categoryId);
        if (mounted) {
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        }
      }
    }
  }

  void _saveChanges() async {
    if (_connectionStatus == ConnectivityResult.none) {
      showOfflineDialog(
        context: context,
        text: "Please turn on your Internet connection",
      );
    } else {
      showLoadingDialog(context: context, text: "Saving");
      await _categoryService.update(
          id: _categoryId,
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
