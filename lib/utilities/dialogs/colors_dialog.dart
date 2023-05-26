import 'package:flutter/material.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/services/colors/colors_model.dart' as color_model;
import 'package:urtask/utilities/extensions/hex_color.dart';

Future showColorsDialog(BuildContext context, ColorController colorService) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return FutureBuilder(
        future: colorService.getAll(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
              if (snapshot.hasData) {
                final colors = snapshot.data as Iterable<color_model.Colors>;
                return SimpleDialog(
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16))),
                    children: List<Widget>.generate(colors.length, (index) {
                      final color = colors.elementAt(index);
                      List<String> selectedColor = [
                        color.id,
                        color.name,
                        color.hex
                      ];
                      return SizedBox(
                        width: 300,
                        child: SimpleDialogOption(
                            onPressed: () =>
                                Navigator.of(context).pop(selectedColor),
                            padding: const EdgeInsets.only(
                                top: 0, left: 12, right: 12),
                            child: ListTile(
                              leading: Icon(
                                Icons.circle,
                                color: HexColor.fromHex(color.hex),
                              ),
                              title: Text(
                                colors.elementAt(index).name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                ),
                              ),
                              shape: const Border(
                                bottom: BorderSide(color: Colors.black26),
                              ),
                              //visualDensity: VisualDensity(vertical: -4),
                            )),
                      );
                    }));
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
}
