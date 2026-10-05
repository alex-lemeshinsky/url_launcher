import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher_app/main.dart' as app;
import 'package:url_launcher_app/models/link_type.dart';

Future<void> _addItem(
  WidgetTester tester,
  String title,
  String url, {
  LinkType type = LinkType.link,
}) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  expect(find.text('Add new url'), findsOneWidget);
  await tester.tap(find.text(type.label));
  await tester.pumpAndSettle();

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), title);
  await tester.enterText(fields.at(1), url);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add, validate, edit, delete and copy URLs', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    final box = Hive.box('URLBox');
    await box.clear();
    await tester.pumpAndSettle();

    // Empty state shows only the title and the FAB.
    expect(find.text('URL launcher'), findsOneWidget);
    expect(find.byType(ListTile), findsNothing);

    // Validation: an invalid url is rejected and nothing is saved.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Bad');
    await tester.enterText(find.byType(TextFormField).at(1), 'nope');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter link in correct way'), findsOneWidget);
    expect(box.length, 0);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Add.
    await _addItem(tester, 'Flutter', 'https://flutter.dev');
    expect(find.text('Flutter'), findsOneWidget);
    expect(box.length, 1);
    expect((box.getAt(0) as dynamic).url, 'https://flutter.dev');

    // Edit via the slide action.
    await tester.drag(find.text('Flutter'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit url'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Flutter docs');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter docs'), findsOneWidget);
    expect(box.length, 1);

    // Delete via the slide action, with confirmation.
    await tester.drag(find.text('Flutter docs'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Are you sure deleting Flutter docs'),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
    expect(find.text('Flutter docs'), findsNothing);
    expect(box.length, 0);

    // Leave saved items behind so the list can be inspected on the simulator.
    await _addItem(tester, 'Flutter', 'https://flutter.dev');
    expect(box.length, 1);

    // View and copy all URLs for a backup, without changing stored items.
    await _addItem(tester, 'Dart', 'https://dart.dev');
    await tester.tap(find.byTooltip('All URLs'));
    await tester.pumpAndSettle();
    const urls = 'https://flutter.dev\nhttps://dart.dev';
    expect(find.text(urls), findsOneWidget);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect((await Clipboard.getData(Clipboard.kTextPlain))?.text, urls);
    expect(find.text('All URLs copied'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Dart'), findsOneWidget);
    expect(box.length, 2);

    // Email: switching the type changes the field, and a bad address is
    // rejected.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Email'));
    await tester.pumpAndSettle();
    expect(find.text('Enter email'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField).at(0), 'Support');
    await tester.enterText(find.byType(TextFormField).at(1), 'help@example');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Enter email in correct way'), findsOneWidget);
    expect(box.length, 2);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // Email and phone items are saved as mailto: and tel: urls.
    await _addItem(tester, 'Support', 'help@example.com', type: LinkType.email);
    await _addItem(
      tester,
      'Hotline',
      '+1 (555) 123-4567',
      type: LinkType.phone,
    );
    expect(box.length, 4);
    expect((box.getAt(2) as dynamic).url, 'mailto:help@example.com');
    expect((box.getAt(3) as dynamic).url, 'tel:+15551234567');

    // Editing reopens with the saved type selected and the scheme hidden.
    await tester.drag(find.text('Hotline'), const Offset(-400, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();
    final picker = find.byType(SegmentedButton<LinkType>);
    expect(tester.widget<SegmentedButton<LinkType>>(picker).selected, {
      LinkType.phone,
    });
    expect(find.text('+15551234567'), findsOneWidget);
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect((box.getAt(3) as dynamic).url, 'tel:+15551234567');
    expect(box.length, 4);
  });
}
