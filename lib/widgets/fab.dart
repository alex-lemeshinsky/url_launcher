import 'package:url_launcher_app/screens/edit_item_screen.dart';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

class FAB extends StatelessWidget {
  const FAB({super.key});

  @override
  Widget build(BuildContext context) {
    return OpenContainer(
      closedElevation: 0,
      closedShape: CircleBorder(),
      closedBuilder: (context, action) {
        return FloatingActionButton(
          elevation: 0,
          onPressed: action,
          child: Icon(Icons.add),
        );
      },
      openBuilder: (context, action) {
        return EditItemScreen();
      },
    );
  }
}
