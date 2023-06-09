import 'package:flutter/material.dart';
import 'package:urtask/services/auth/auth_service.dart';
import 'package:urtask/services/categories/categories_controller.dart';
import 'package:urtask/services/categories/categories_model.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/category/category_detail_view.dart';
import 'package:urtask/views/category/create_category_view.dart';

class CategoriesView extends StatefulWidget {
  const CategoriesView({super.key});

  @override
  State<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends State<CategoriesView> {
  late final CategoryController _categoryService;
  late final ColorController _colorService;
  final userId = AuthService.firebase().currentUser!.id;

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
        elevation: 0,
        title: const Text("Event Categories",
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints(
          maxHeight: 720.0,
        ),
        child: StreamBuilder(
          stream: _categoryService.getAll(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final categories = snapshot.data as Iterable<Categories>;
                  return ListView.builder(
                    padding: const EdgeInsets.only(top: 4, right: 12, left: 12),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories.elementAt(index);
                      return FutureBuilder(
                        future: _colorService.get(id: category.colorId),
                        builder: (context, snapshot) {
                          switch (snapshot.connectionState) {
                            case ConnectionState.done:
                              if (snapshot.hasData) {
                                final color =
                                    snapshot.data as color_model.Colors;
                                return ListTile(
                                  onTap: () => _toCategoryDetail(
                                    category: category,
                                    color: color,
                                  ),
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
                                  shape: const Border(
                                    bottom: BorderSide(color: Colors.black26),
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
                  );
                } else {
                  return Column();
                }
              default:
                return Column();
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        elevation: 0,
        onPressed: () => _toCreateCategory(),
        tooltip: 'Increment',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _toCategoryDetail({
    required Categories category,
    required color_model.Colors color,
  }) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryDetailView(
          categoryId: category.id,
          categoryName: category.name,
          colorId: color.id,
          colorName: color.name,
          colorHex: color.hex,
        ),
      ),
    );
  }

  void _toCreateCategory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CreateCategoryView(),
      ),
    );
  }
}
