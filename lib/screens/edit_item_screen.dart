import 'package:url_launcher_app/models/item.dart';
import 'package:url_launcher_app/providers/db_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditItemScreen extends StatefulWidget {
  const EditItemScreen({super.key, this.index, this.title, this.url});

  final int? index; // used as key in hive db
  final String? title;
  final String? url;

  @override
  State<EditItemScreen> createState() => _EditItemScreenState();
}

class _EditItemScreenState extends State<EditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _urlFocusNode = FocusNode();

  String? _title;
  String? _url;

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _urlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    DbProvider dbProvider = Provider.of<DbProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title == null ? "Add new url" : "Edit url"),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                autofocus: true,
                initialValue: widget.title,
                focusNode: _titleFocusNode,
                onSaved: (value) => _title = value,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(labelText: "Enter title"),
                onEditingComplete: () => _urlFocusNode.requestFocus(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Enter title';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: widget.url ?? "https://",
                focusNode: _urlFocusNode,
                onSaved: (value) =>
                    _url = value!.replaceAll("https://https://", "https://"),
                decoration: InputDecoration(labelText: "Enter url"),
                validator: (value) {
                  //regexp to check url
                  final regexp = RegExp(
                    r"(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})",
                  );

                  if (value == null || value.isEmpty) {
                    return 'Enter url';
                  } else if (!regexp.hasMatch(value)) {
                    return "Enter link in correct way 'https://example.com'";
                  }

                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    dbProvider.addOrUpdateItem(
                      item: Item(title: _title!, url: _url!),
                      index: widget.index,
                    );
                    Navigator.pop(context);
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
