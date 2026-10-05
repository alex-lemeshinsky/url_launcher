import 'package:url_launcher_app/hive_registrar.g.dart';
import 'package:url_launcher_app/providers/db_provider.dart';
import 'package:url_launcher_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapters();
  await Hive.openBox('URLBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [Provider<DbProvider>(create: (_) => DbProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'URL launcher',
        home: const HomeScreen(),
        darkTheme: ThemeData.dark().copyWith(
          colorScheme: ColorScheme.dark(
            secondary: Colors.blue,
            primary: Colors.blue,
          ),
        ),
      ),
    );
  }
}
