import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:gamelog/product_catalog_model.dart';

class ProductCatalogApi {
  const ProductCatalogApi({this.bundle, this.client});

  static const remoteCatalogUrl =
      'https://gist.githubusercontent.com/vanemrey07/4a5db2035ce4c5e39307e497193254c8/raw/16cb97d73b80117628239ca7187fb001d9f3eb1f/gamelog.json';
  static const catalogAsset = 'assets/product_catalog.json';

  final AssetBundle? bundle;
  final http.Client? client;

  Future<List<ProductCatalogItem>> fetchCatalog() async {
    final uri = Uri.parse(remoteCatalogUrl);
    try {
      final response = await (client?.get(uri) ?? http.get(uri)).timeout(
        const Duration(seconds: 8),
      );
      if (response.statusCode == 200) {
        return _parseCatalog(response.body);
      }
    } on http.ClientException {
      return _loadBundledCatalog();
    } on TimeoutException {
      return _loadBundledCatalog();
    }

    return _loadBundledCatalog();
  }

  Future<List<ProductCatalogItem>> fetchServices() async {
    final catalog = await fetchCatalog();
    return catalog
        .where((item) => item.category == 'Service')
        .toList(growable: false);
  }

  List<ProductCatalogItem> _parseCatalog(String rawJson) {
    final decoded = jsonDecode(rawJson);
    final List<dynamic> entries;
    if (decoded is List<dynamic>) {
      entries = decoded;
    } else if (decoded is Map<String, dynamic> &&
        decoded['gamelog'] is List<dynamic>) {
      entries = decoded['gamelog'] as List<dynamic>;
    } else {
      throw const FormatException(
        'Expected a product array or an object containing a gamelog array.',
      );
    }

    return entries
        .map((item) {
          if (item is! Map) {
            throw const FormatException('Each product must be a JSON object.');
          }
          return ProductCatalogItem.fromJson(Map<String, dynamic>.from(item));
        })
        .toList(growable: false);
  }

  Future<List<ProductCatalogItem>> _loadBundledCatalog() async {
    final rawJson = await (bundle ?? rootBundle).loadString(catalogAsset);
    return _parseCatalog(rawJson);
  }
}
