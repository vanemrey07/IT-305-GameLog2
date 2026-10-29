import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamelog/product_catalog_api.dart';
import 'package:gamelog/product_catalog_model.dart';
import 'package:gamelog/product_catalog_page.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  const products = [
    {
      'id': 'product-001',
      'name': 'GameLog Premium',
      'description': 'Cloud tools for tracking games.',
      'category': 'Product',
      'priceLabel': 'Premium',
      'icon': 'workspace_premium',
    },
    {
      'id': 'product-002',
      'name': 'Controller Stand',
      'description': 'Keep a controller ready to play.',
      'category': 'Item',
      'priceLabel': '\$24.99',
      'icon': 'controller',
    },
  ];

  test('fetchCatalog sends a GET and maps a JSON product array', () async {
    final client = MockClient((request) async {
      expect(request.method, 'GET');
      expect(request.url.toString(), ProductCatalogApi.remoteCatalogUrl);
      return http.Response(jsonEncode(products), 200);
    });

    final result = await ProductCatalogApi(client: client).fetchCatalog();

    expect(result, hasLength(2));
    expect(result.first, isA<ProductCatalogItem>());
    expect(result.first.id, 'product-001');
    expect(result.first.priceLabel, 'Premium');
    expect(result.last.priceLabel, '\$24.99');
    client.close();
  });

  testWidgets('catalog search filters products by matching text', (
    tester,
  ) async {
    final client = MockClient(
      (_) async => http.Response(jsonEncode(products), 200),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductCatalogPage(api: ProductCatalogApi(client: client)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('GameLog Premium'), findsOneWidget);
    expect(find.text('Controller Stand'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'cloud');
    await tester.pumpAndSettle();

    expect(find.text('GameLog Premium'), findsOneWidget);
    expect(find.text('Controller Stand'), findsNothing);
    client.close();
  });
}
