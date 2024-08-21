import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_practice/logic/product.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final shoppingBox = Hive.box("shopping_box");

  List<Product> items = [];

  @override
  void initState() {
    super.initState();
    refreshItem();
  }

  void refreshItem() {
    final data = shoppingBox.keys.map((key) {
      final item = shoppingBox.get(key);
      // return {
      //   "key": key,
      //   "name": item["name"],
      //   "quantity": item["quantity"],
      // };
      return Product(key: key, name: item['name'], quantity: item['quantity']);
    }).toList();
    setState(() {
      items = data;
    });
    print("Product count: ${items.length}");
  }

  Future<void> createItem(Product newItem) async {
    shoppingBox.add(newItem);
    refreshItem();
  }

  Future<void> updateItem(int itemKey, Product item) async {
    await shoppingBox.put(itemKey, item);
    refreshItem();
  }

  Future<void> deleteItem(int itemKey) async {
    await shoppingBox.delete(itemKey);
    refreshItem();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Item has been successfully deleted"),
      ),
    );
  }

  void showForm(BuildContext context, int? itemKey) async {
    if (itemKey != null) {
      final existingItem = items.firstWhere((element) => element.key == itemKey);
      nameController.text = existingItem.name;
      quantityController.text = existingItem.quantity;
    }
    showModalBottomSheet(
      context: context,
      //isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          top: 15,
          right: 15,
          left: 15,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              TextField(
                controller: nameController,
                keyboardType: TextInputType.name,
                decoration: InputDecoration(hintText: 'Name'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(hintText: 'Quantity'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  itemKey == null
                      ? createItem(Product(
                          name: nameController.text,
                          quantity: quantityController.text,
                        ))
                      : updateItem(
                          itemKey,
                          Product(
                            name: nameController.text,
                            quantity: quantityController.text,
                          ));
                  nameController.text = '';
                  quantityController.text = '';
                  Navigator.pop(context);
                },
                child: Text(itemKey == null ? 'Create New' : 'Update Item'),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hive Flutter'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context1, index) {
              final currentItem = items[index];
              return Card(
                elevation: 3,
                child: ListTile(
                  title: Text(currentItem.name),
                  subtitle: Text(currentItem.quantity),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          showForm(context, currentItem.key);
                        },
                        icon: Icon(Icons.edit),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteItem(currentItem.key!);
                        },
                        icon: Icon(Icons.delete),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showForm(context, null);
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
