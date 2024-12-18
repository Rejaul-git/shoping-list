import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/grocery_item.dart';
import 'package:shoping_list/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isloaded = true;
  String? _error;
  @override
  void initState() {
    super.initState();
    _loadItem();
  }

  void _loadItem() async {
    final url = Uri.https(
        'my-app-e172a-default-rtdb.firebaseio.com', 'shopping-list.json');
// if internet or other error happend we use try and catch block for the http request like post,get,delete
    try {
      final response = await http.get(url);
      if (response.statusCode >= 404) {
        setState(() {
          _error = 'something proble to fatch the data';
        });
      }
//  if response.body does not provide data it sent string null value for firebase db
      if (response.body == 'null') {
        setState(() {
          _isloaded = false;
        });
        return;
      }
      final Map<String, dynamic> listData = json.decode(response.body);
      final List<GroceryItem> _loadedItems = [];
      for (final item in listData.entries) {
        final category = categories.entries
            .firstWhere(
                (category) => category.value.title == item.value['category'])
            .value;
        _loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ));
      }
      setState(() {
        _groceryItems = _loadedItems;
        _isloaded = false;
      });
    } catch (error) {
      setState(() {
        _error = 'something wrong with this app';
      });
    }
  }

  void addItem() async {
    final newItem = await Navigator.of(context)
        .push<GroceryItem>(MaterialPageRoute(builder: (ctx) {
      return const NewItem();
    }));

    if (newItem == null) {
      return;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) {
    final url = Uri.https('my-app-e172a-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');
    http.delete(url);
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(child: Text('no data found'));
    if (_isloaded) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = content = ListView.builder(
          itemCount: _groceryItems.length,
          itemBuilder: (ctx, index) {
            return Dismissible(
              key: Key(_groceryItems[index].name),
              onDismissed: (direction) {
                _removeItem(_groceryItems[index]);
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text('$index dismissed')));
              },
              background: Container(
                color: Colors.red,
                margin: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: ListTile(
                title: Text(_groceryItems[index].name),
                leading: Container(
                  width: 20,
                  height: 20,
                  color: _groceryItems[index].category.color,
                ),
                trailing: Text(_groceryItems[index].quantity.toString()),
              ),
            );
          });
    }
    if (_error != null) {
      content = Center(child: Text(_error!));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Your Groceries'), actions: [
        IconButton(onPressed: addItem, icon: const Icon(Icons.add))
      ]),
      body: content,
    );
  }
}
