import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/utilities/dialogs/discard_dialog.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/category/categories_view.dart';
import 'package:urtask/views/color_view.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
  late final ColorController _colorService;
  late final CategoryController _categoryService;
  late final TextEditingController _eventCategoryTitle;

  String colorId = "color1";
  String colorName = "Tomato";
  String colorHex = "#D50000";
  final userId = AuthService.firebase().currentUser!.id;
  late final FocusNode eventTitleFocus;
  bool eventIsEdited = false;

  @override
  void initState() {
    _colorService = ColorController();
    _categoryService = CategoryController();
    _eventCategoryTitle = TextEditingController();
    eventTitleFocus = FocusNode();
    super.initState();
  }

  @override
  void dispose() {
    _eventCategoryTitle.dispose();
    super.dispose();
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
          if (eventIsEdited || _eventCategoryTitle.text.isNotEmpty) {
            final shouldDiscard = await showDiscardDialog(
              context,
              "Are you sure you want to discard this event?",
            );
            if (shouldDiscard) {
              if (mounted) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CategoryView(),
                  ),
                );
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
        child: TextButton(
          onPressed: () async {
            _categoryService.create(
                userId: userId,
                colorId: colorId,
                name: _eventCategoryTitle.text.isNotEmpty
                    ? _eventCategoryTitle.text
                    : "My Category");
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CategoryView(),
              ),
            );
          },
          child: const Text("Save", style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }
}
