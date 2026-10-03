import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:url_launcher_app/main.dart';
import 'package:url_launcher_app/models/item.dart';

void main() {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  late Directory directory;
  late Box box;
  String? clipboardText;
  bool clipboardFails = false;

  setUpAll(() {
    Hive.registerAdapter(ItemAdapter());
  });

  setUp(() async {
    directory = await Directory.systemTemp.createTemp('all_urls_test_');
    Hive.init(directory.path);
    box = await Hive.openBox('URLBox');
    clipboardText = 'Existing clipboard';
    clipboardFails = false;
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/quick_actions'),
      (_) async => null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (call) async {
        if (call.method == 'Clipboard.setData') {
          if (clipboardFails) {
            throw PlatformException(code: 'clipboard_unavailable');
          }
          clipboardText = (call.arguments as Map)['text'] as String;
        }
        return null;
      },
    );
  });

  tearDown(() async {
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/quick_actions'),
      null,
    );
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      null,
    );
    await Hive.close();
    await directory.delete(recursive: true);
  });

  Future<void> openAllUrls(WidgetTester tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
    expect(find.byTooltip('All URLs'), findsOneWidget);
    await tester.tap(find.byTooltip('All URLs'));
    await tester.pumpAndSettle();
    expect(find.text('All URLs'), findsOneWidget);
  }

  testWidgets('view and copy every saved URL without changing saved items', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await box.addAll([
        Item(title: 'Flutter', url: 'https://flutter.dev'),
        Item(
          title: 'Search',
          url: 'https://example.com/?q=hello%20world#results',
        ),
        Item(title: 'Flutter again', url: 'https://flutter.dev'),
      ]);
    });
    const urls =
        'https://flutter.dev\n'
        'https://example.com/?q=hello%20world#results\n'
        'https://flutter.dev';

    await openAllUrls(tester);
    expect(find.text(urls), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText, urls);
    expect(find.text('All URLs copied'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Flutter'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.text('Flutter again'), findsOneWidget);
    expect(box.length, 3);
    expect(
      (box.getAt(1) as Item).url,
      'https://example.com/?q=hello%20world#results',
    );
  });

  testWidgets('an empty URL list cannot overwrite the clipboard', (
    tester,
  ) async {
    await openAllUrls(tester);
    expect(find.text('No saved URLs yet'), findsOneWidget);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText, 'Existing clipboard');
    expect(find.text('All URLs copied'), findsNothing);
  });

  testWidgets('the URL view and copy button follow saved item changes', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await box.add(Item(title: 'First', url: 'https://example.com/first'));
    });
    await openAllUrls(tester);

    await tester.runAsync(() async {
      await box.putAt(
        0,
        Item(title: 'Updated', url: 'https://example.com/new'),
      );
      await box.add(Item(title: 'Second', url: 'https://example.com/second'));
    });
    await tester.pumpAndSettle();
    const urls = 'https://example.com/new\nhttps://example.com/second';
    expect(find.text(urls), findsOneWidget);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText, urls);

    await tester.runAsync(() async => box.clear());
    await tester.pumpAndSettle();
    expect(find.text('No saved URLs yet'), findsOneWidget);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText, urls);
  });

  testWidgets('all URLs are copied even when the list exceeds the screen', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await box.addAll(
        List.generate(
          100,
          (index) =>
              Item(title: 'URL $index', url: 'https://example.com/$index'),
        ),
      );
    });
    await openAllUrls(tester);
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText!.split('\n'), hasLength(100));
    expect(clipboardText!.split('\n').first, 'https://example.com/0');
    expect(clipboardText!.split('\n').last, 'https://example.com/99');
    expect(tester.takeException(), isNull);
  });

  testWidgets('a clipboard failure shows an error and allows retry', (
    tester,
  ) async {
    await tester.runAsync(() async {
      await box.add(Item(title: 'Flutter', url: 'https://flutter.dev'));
    });
    await openAllUrls(tester);
    clipboardFails = true;
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(find.text('Could not copy URLs. Please try again.'), findsOneWidget);
    expect(find.text('All URLs copied'), findsNothing);
    expect(clipboardText, 'Existing clipboard');

    clipboardFails = false;
    await tester.tap(find.text('Copy all URLs'));
    await tester.pumpAndSettle();
    expect(clipboardText, 'https://flutter.dev');
    expect(find.text('All URLs copied'), findsOneWidget);
  });
}
