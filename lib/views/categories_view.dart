import 'package:flutter/material.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/utilities/extensions/hex_color.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView> {
  late final CategoryController _categoryService;
  late final ColorController _colorService;

  @override
  void initState() {
    _categoryService = CategoryController();
    _colorService = ColorController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Event Categories", style: TextStyle(color: Colors.white)),
      ),
      //backgroundColor: const Color.fromARGB(31, 133, 133, 133),
      body: StreamBuilder(
        stream: _categoryService.getAll(userId: "default"),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final categories = snapshot.data as Iterable<Categories>;
                return ListView.builder(
                  padding: const EdgeInsets.only(
            top: 4, right: 12, left: 12
          ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories.elementAt(index);
                    return FutureBuilder(
                      future: _colorService.get(id: category.colorId),
                      builder: (context, snapshot) {
                        switch (snapshot.connectionState) {
                          case ConnectionState.done:
                            if (snapshot.hasData) {
                              final color = snapshot.data as color_model.Colors;
                              return ListTile(
                                leading: Icon(
                                  Icons.circle,
                                  color: HexColor.fromHex(color.hex),
                                ),
                                title: Text(
                                  category.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 20),
                                ),
                                shape: Border(bottom: BorderSide(color: Colors.black26))
                              );
                            } else {
                              return const CircularProgressIndicator();
                            }
                          default:
                            return const CircularProgressIndicator();
                        }
                      },
                    );
                  },
                );
              } else {
                return Column();
              }
            default:
              return Column();
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        tooltip: 'Increment',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
