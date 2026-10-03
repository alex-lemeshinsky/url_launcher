import 'package:url_launcher_app/functions/launch_url.dart';
import 'package:url_launcher_app/models/item.dart';
import 'package:url_launcher_app/providers/db_provider.dart';
import 'package:url_launcher_app/screens/all_urls_screen.dart';
import 'package:url_launcher_app/screens/edit_item_screen.dart';
import 'package:url_launcher_app/widgets/confirmation_dialog.dart';
import 'package:url_launcher_app/widgets/fab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:quick_actions/quick_actions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    DbProvider dbProvider = Provider.of<DbProvider>(context, listen: false);

    final QuickActions quickActions = const QuickActions();
    quickActions.initialize((shortcutType) {
      launchURL(shortcutType, context);
    });

    return Scaffold(
      appBar: AppBar(
        title: Text("URL launcher"),
        actions: [
          IconButton(
            tooltip: 'All URLs',
            icon: const Icon(Icons.list_alt),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AllUrlsScreen()),
            ),
          ),
        ],
      ),
      floatingActionButton: const FAB(),
      body: StreamBuilder(
        stream: dbProvider.itemsStream,
        builder: (context, snapshot) {
          quickActions.setShortcutItems(
            List.generate(dbProvider.items.length, (index) {
              Item item = dbProvider.items[index];
              return ShortcutItem(
                type: item.url,
                localizedTitle: item.title,
                icon: "link",
              );
            }),
          );

          return ListView.separated(
            itemCount: dbProvider.items.length,
            separatorBuilder: (BuildContext context, int index) => Divider(),
            itemBuilder: (BuildContext context, int index) {
              Item item = dbProvider.items[index];

              return _StaggeredEntry(
                key: ValueKey(item),
                position: index,
                child: Card(
                  elevation: 10,
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: ScrollMotion(),
                      children: [
                        SlidableAction(
                          label: "Edit",
                          backgroundColor: Colors.blue,
                          icon: Icons.edit,
                          onPressed: (ctx) => Navigator.push(
                            ctx,
                            MaterialPageRoute(
                              builder: (_) => EditItemScreen(
                                index: index,
                                title: item.title,
                                url: item.url,
                              ),
                            ),
                          ),
                        ),
                        SlidableAction(
                          label: "Delete",
                          backgroundColor: Colors.red,
                          icon: Icons.delete,
                          onPressed: (ctx) => ConfirmationDialog(
                            item: item,
                            index: index,
                          ).show(ctx),
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text(item.title),
                      trailing: Icon(Icons.chevron_left),
                      onTap: () async => await launchURL(item.url, context),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

/// Fades an item in while sliding it up 50px. Items further down the list
/// start slightly later, which gives the staggered entrance.
class _StaggeredEntry extends StatelessWidget {
  const _StaggeredEntry({
    super.key,
    required this.position,
    required this.child,
  });

  final int position;
  final Widget child;

  static const _duration = Duration(milliseconds: 375);
  static const _stagger = Duration(milliseconds: 75);
  static const _maxStaggeredItems = 10;

  @override
  Widget build(BuildContext context) {
    final delay = _stagger * position.clamp(0, _maxStaggeredItems);
    final total = delay + _duration;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: total,
      curve: Interval(
        delay.inMilliseconds / total.inMilliseconds,
        1,
        curve: Curves.ease,
      ),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 50 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}
