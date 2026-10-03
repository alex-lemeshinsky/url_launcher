import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher_app/models/item.dart';
import 'package:url_launcher_app/providers/db_provider.dart';

class AllUrlsScreen extends StatelessWidget {
  const AllUrlsScreen({super.key});

  Future<void> _copyUrls(BuildContext context, String urls) async {
    String message;
    try {
      await Clipboard.setData(ClipboardData(text: urls));
      message = 'All URLs copied';
    } on PlatformException {
      message = 'Could not copy URLs. Please try again.';
    }

    if (!context.mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final dbProvider = context.read<DbProvider>();

    return StreamBuilder(
      stream: dbProvider.itemsStream,
      builder: (context, snapshot) {
        final items = dbProvider.items.cast<Item>();
        final urls = items.map((item) => item.url).join('\n');

        return Scaffold(
          appBar: AppBar(title: const Text('All URLs')),
          body: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${items.length} saved URL${items.length == 1 ? '' : 's'}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Copy these URLs and paste them into a note or document '
                    'for backup.',
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: items.isEmpty
                        ? const Center(child: Text('No saved URLs yet'))
                        : Scrollbar(
                            child: SingleChildScrollView(
                              child: SelectableText(
                                urls,
                                textDirection: TextDirection.ltr,
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: FilledButton.icon(
                onPressed: items.isEmpty
                    ? null
                    : () => _copyUrls(context, urls),
                icon: const Icon(Icons.copy),
                label: const Text('Copy all URLs'),
              ),
            ),
          ),
        );
      },
    );
  }
}
