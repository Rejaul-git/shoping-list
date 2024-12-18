import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shoping_list/data/categories.dart';
import 'package:shoping_list/models/category.dart';
import 'package:shoping_list/models/grocery_item.dart';

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  var _isSending = false;
  final _formKey = GlobalKey<FormState>();
  var _setName = '';
  var _enteredQuantity = 1;
  var _seletedCategory = categories[Categories.vegetables]!;

  void _sevItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _isSending = true;
      });
      final url = Uri.https(
          'my-app-e172a-default-rtdb.firebaseio.com', 'shopping-list.json');
      final response = await http.post(url,
          body: json.encode({
            'name': _setName,
            'quantity': _enteredQuantity,
            'category': _seletedCategory.title,
          }),
          headers: {
            'Content-Type': 'application/json',
          });
      final Map<String, dynamic> resData = json.decode(response.body);
// if we want to use context under of a future await  we must use if chakeing like this:
      if (!context.mounted) {
        return;
      }
      Navigator.of(context).pop(GroceryItem(
          id: resData['name'],
          name: _setName,
          quantity: _enteredQuantity,
          category: _seletedCategory));
    }
  }
// when _formKey.currentState!.save(); will be called then (onSaved,onChanged) function will be called and it take a paramiter where
// data will be stored and then we can use then to our need we can store this value in our variable.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('new item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text(
                  textAlign: TextAlign.center,
                  'Fill the Form First',
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  maxLength: 50,
                  decoration: const InputDecoration(
                      hintText: 'Item Name', label: Text('Name')),
                  validator: (value) {
                    if (value == null ||
                        value.isEmpty ||
                        value.trim().length <= 1 ||
                        value.trim().length > 50) {
                      return 'Must be valid input ';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    _setName = value!;
                  },
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                            hintText: 'Item Quantity', label: Text('Quantity')),
                        initialValue: _enteredQuantity.toString(),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
// (!) this means value must be exist
                              int.tryParse(value)! <= 0) {
                            return 'Must be valid input ';
                          }
                          return null;
                        },
                        onSaved: (value) {
                          _enteredQuantity = int.parse(value!);
                        },
                      ),
                    ),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                        child: DropdownButtonFormField(
// (value:) this value always updated when we selected our dropdown manu so we can use an initialvalue
                            value: _seletedCategory,
                            items: [
                              for (final category in categories.entries)
                                DropdownMenuItem(
                                    value: category.value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          color: category.value.color,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text(category.value.title)
                                      ],
                                    ))
                            ],
                            onChanged: (value) {
                              setState(() {
                                _seletedCategory = value!;
                              });
                            }))
                  ],
                ),
                const SizedBox(
                  height: 8,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                        onPressed: _isSending
                            ? null
                            : () {
                                _formKey.currentState!.reset();
                              },
                        child: const Text('Reset')),
                    ElevatedButton(
                        onPressed: _isSending ? null : _sevItem,
                        child: _isSending
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(),
                              )
                            : const Text('Submit'))
                  ],
                )
              ],
            )),
      ),
    );
  }
}
