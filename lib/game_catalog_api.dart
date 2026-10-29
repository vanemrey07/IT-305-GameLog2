import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:gamelog/game_model.dart';

class GameCatalogApi {
  const GameCatalogApi({this._bundle});

  static const String catalogAsset = 'assets/game_catalog.json';

  final AssetBundle? _bundle;

  Future<List<GameEntry>> fetchCatalog() async {
    final assetBundle = _bundle ?? rootBundle;
    final rawJson = await assetBundle.loadString(catalogAsset);
    final decoded = jsonDecode(rawJson) as List<dynamic>;

    return decoded
        .map(
          (item) => GameEntry.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList(growable: false); 
  }

  Future<List<GameEntry>> search(String query) async {
    final normalizedQuery = query.trim().toLowerCase();
    final catalog = await fetchCatalog();

    if (normalizedQuery.isEmpty) {
      return catalog;
    }

    return catalog
        .where((game) => game.title.toLowerCase().contains(normalizedQuery))
        .toList(growable: false);
  }
}
