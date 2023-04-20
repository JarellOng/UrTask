import 'package:flutter/material.dart';
import 'package:urtask/service/colors/colors_controller.dart';
import 'package:urtask/service/colors/colors_model.dart' as color_model;
import 'package:urtask/utilities/extensions/hex_color.dart';

class ColorView extends StatefulWidget {
  const ColorView({super.key});

  @override
  State<ColorView> createState() => _ColorViewState();
}

class _ColorViewState extends State<ColorView> {
  late final ColorController _colorService;

  @override
  void initState() {
    _colorService = ColorController();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors"),
      ),
      backgroundColor: const Color.fromARGB(31, 133, 133, 133),
      body: FutureBuilder(
        future: _colorService.getAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.done:
              if (snapshot.hasData) {
                final colors = snapshot.data as Iterable<color_model.Colors>;
                return ListView.builder(
                  itemCount: colors.length,
                  itemBuilder: (context, index) {
                    final color = colors.elementAt(index);
                    return ListTile(
                      title: Text(
                        color.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      textColor: HexColor.fromHex(color.hex),
                    );
                  },
                );
              } else {
                return const CircularProgressIndicator();
              }
            default:
              return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
