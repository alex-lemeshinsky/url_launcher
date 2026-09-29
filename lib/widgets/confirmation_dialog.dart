import 'package:url_launcher_app/models/item.dart';
import 'package:url_launcher_app/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfirmationDialog {
  final Item item;
  final int index;
  ConfirmationDialog({required this.item, required this.index});

  void show(BuildContext context) async {
    DbProvider dbProvider = Provider.of<DbProvider>(context, listen: false);

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm'),
          content: Text("Are you sure deleting ${item.title} item?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                dbProvider.deleteItem(index: index);
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
