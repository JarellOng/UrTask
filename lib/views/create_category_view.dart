import 'package:flutter/material.dart';
import 'package:urtask/color.dart';
import 'package:urtask/services/colors/colors_controller.dart';
import 'package:urtask/utilities/extensions/hex_color.dart';
import 'package:urtask/views/categories_view.dart';
import 'package:urtask/views/color_view.dart';

class CreateCategoryView extends StatefulWidget {
  const CreateCategoryView({super.key});

  @override
  State<CreateCategoryView> createState() => _CreateCategoryViewState();
}

class _CreateCategoryViewState extends State<CreateCategoryView> {
   late final ColorController _colorService;

  String colorName = "Tomato";
  String colorHex = "#D50000";

  @override
  void initState() {
    _colorService = ColorController();
    super.initState();
  }
  /*
  late final TextEditingController _eventTitle;

  @override
  void initState(){
    _eventTitle = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _eventTitle.dispose();
    super.dispose();
  }
  */

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Event Category",
            style: TextStyle(color: Colors.white)),
        iconTheme: IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_outlined),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CategoryView(),
            ),
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                //controller: _eventTitle,
                enableSuggestions: false,
                autocorrect: false,
                maxLines: 2,
                decoration: const InputDecoration(
                    hintText: "Event Category Name",
                    hintStyle: TextStyle(fontSize: 18)),
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
                        title: Text(colorName, style: TextStyle(fontSize: 20)),
                        leading: Icon(
                          Icons.circle,
                          color: HexColor.fromHex(colorHex),
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(width: 0.5),
                          borderRadius: BorderRadius.circular(20)
                        ),
                        visualDensity: VisualDensity(vertical: -4),
                        onTap: () async {
                          final colorDetail = await showColorsDialog(context, _colorService);
                          if (colorDetail.isNotEmpty) {
                      setState(() {
                        colorName = colorDetail[0];
                        colorHex = colorDetail[1];
                      });
                    }
                  },
                      ))
                ],
              ),
            ],
          )),
          Transform.translate(offset: Offset(0,460),
          child: Divider(
              height: 1,
              thickness: 2,
            ),)
          
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(bottom: 6, left: 100, right: 100),
        
        child: TextButton(
              onPressed: () async {
                // final startDay = _eventStartDay.selectedItem;
                // final startHour = _eventStartHour.selectedItem;
                // final startMinute = _eventStartMinute.selectedItem;
                // print(startDay);
                // print(startMinute);
              },
              child: const Text("Save", style: TextStyle(fontSize: 18)),
            ),
      ),
          
    );
  }
}
