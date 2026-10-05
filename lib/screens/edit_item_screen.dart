import 'package:url_launcher_app/models/item.dart';
import 'package:url_launcher_app/models/link_type.dart';
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
  late LinkType _type;
  late final TextEditingController _urlController;
  final _urlFieldKey = GlobalKey<FormFieldState<String>>();

  String? _title;
  String? _url;

  @override
  void initState() {
    super.initState();
    final url = widget.url;
    _type = url == null ? LinkType.link : LinkType.fromUrl(url);
    _urlController = TextEditingController(
      text: url == null ? _type.prefill : _type.displayValue(url),
    );
  }

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _urlFocusNode.dispose();
    _urlController.dispose();
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
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: SegmentedButton<LinkType>(
                  segments: [
                    for (final type in LinkType.values)
                      ButtonSegment(value: type, label: Text(type.label)),
                  ],
                  selected: {_type},
                  onSelectionChanged: (selection) {
                    setState(() {
                      _type = selection.single;
                      // Clears a validation error left from the old type.
                      _urlFieldKey.currentState!.reset();
                      _urlController.text = _type.prefill;
                    });
                    // Refocus after the rebuild so the keyboard reopens with
                    // the new type's layout; iOS ignores in-place changes.
                    _urlFocusNode.unfocus();
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => _urlFocusNode.requestFocus(),
                    );
                  },
                ),
              ),
              TextFormField(
                key: _urlFieldKey,
                controller: _urlController,
                focusNode: _urlFocusNode,
                keyboardType: _type.keyboardType,
                onSaved: (value) => _url = _type.toUrl(value!),
                decoration: InputDecoration(labelText: _type.fieldLabel),
                validator: _type.validate,
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
