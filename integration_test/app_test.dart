import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:integration_test/integration_test.dart';
import 'package:url_launcher_app/main.dart' as app;

Future<void> _addItem(WidgetTester tester, String title, String url) async {
  await tester.tap(find.byType(FloatingActionButton));
  await tester.pumpAndSettle();
  expect(find.text('Add new url'), findsOneWidget);

  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), title);
  await tester.enterText(fields.at(1), url);
  await tester.tap(find.text('Save'));
  await tester.pumpAndSettle();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('add, validate, edit, delete and persist URLs', (tester) async {
    app.main();
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

    // Leave one item behind so the list can be inspected on the simulator.
    await _addItem(tester, 'Flutter', 'https://flutter.dev');
    expect(box.length, 1);
  });
}
