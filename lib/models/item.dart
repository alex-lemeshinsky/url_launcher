import 'package:hive_ce/hive.dart';
part 'item.g.dart';

@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  String url;

  Item({required this.title, required this.url});
}
