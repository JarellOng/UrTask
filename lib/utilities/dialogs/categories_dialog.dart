import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/utilities/extensions/hex_color.dart';
final userId = AuthService.firebase().currentUser!.id;
Future<List<String>> showCategoriesDialog(
  BuildContext context,
  CategoryController categoryService,
  ColorController colorService,
) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return StreamBuilder(
        stream: categoryService.getAll(userId: userId),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.active:
              if (snapshot.hasData) {
                final categories = snapshot.data as Iterable<Categories>;
                return SimpleDialog(
                  children: List<Widget>.generate(
                    categories.length,
                    (index) {
                      final category = categories.elementAt(index);
                      return FutureBuilder(
                        future: colorService.get(id: category.colorId),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              if (snapshot.hasData) {
                                final color =
                                    snapshot.data as color_model.Colors;
                                List<String> selectedCategory = [
                                  category.id,
                                  category.name,
                                  color.hex
                                ];
                                return SimpleDialogOption(
                                  onPressed: () => Navigator.of(context)
                                      .pop(selectedCategory),
                                  child: Text(
                                    categories.elementAt(index).name,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: HexColor.fromHex(color.hex),
                                    ),
                                  ),
                                );
                              } else {
                                return Column();
                              }
                            default:
                              return Column();
                          }
                        },
                      );
                    },
                  ),
                );
              } else {
                return Column();
              }
            default:
              return Column();
          }
        },
      );
    },
  ).then((value) => value ?? []);
}
