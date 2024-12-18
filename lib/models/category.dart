import 'package:flutter/material.dart';

enum Categories {
  vegetables,
  fruit,
  meat,
  dairy,
  carbs,
  spices,
  convenience,
  hygiene,
  other,
  sweets
}

class Category {
  const Category(this.title, this.color);
  final String title;
  final Color color;
}
