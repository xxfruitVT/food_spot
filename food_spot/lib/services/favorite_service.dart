class FavoriteService {
  static final List<dynamic> _favorites = [];

  static List<dynamic> get favorites => _favorites;

  static void addFavorite(dynamic food) {
    // hindari double data
    if (!_favorites.any((item) => item['name'] == food['name'])) {
      _favorites.add(food);
    }
  }

  static void removeFavorite(dynamic food) {
    _favorites.removeWhere((item) => item['name'] == food['name']);
  }

  static bool isFavorite(dynamic food) {
    return _favorites.any((item) => item['name'] == food['name']);
  }
}
