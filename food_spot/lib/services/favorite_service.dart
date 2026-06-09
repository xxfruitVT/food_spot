import 'package:flutter/material.dart';

class FavoriteService {
  static final ValueNotifier<List<dynamic>> favorites =
      ValueNotifier<List<dynamic>>([]);

  static void addFavorite(dynamic food) {
    final list = List<dynamic>.from(favorites.value);

    // cegah duplicate (pakai id kalau ada)
    final exists = list.any((item) => item['id'] == food['id']);

    if (!exists) {
      list.add(food);
      favorites.value = list;
    }
  }

  static void removeFavorite(dynamic food) {
    final list = List<dynamic>.from(favorites.value);

    list.removeWhere(
      (item) => item['name'] == food['name'] && item['image'] == food['image'],
    );

    favorites.value = list;
  }

  static void clearAll() {
    favorites.value = [];
  }
}
