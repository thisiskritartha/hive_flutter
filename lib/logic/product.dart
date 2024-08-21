import 'package:hive/hive.dart';

part 'product.g.dart';

@HiveType(typeId: 1)
class Product {
  Product({this.key, required this.name, required this.quantity});

  @HiveField(0)
  int? key;

  @HiveField(1)
  String name;

  @HiveField(2)
  String quantity;
}
