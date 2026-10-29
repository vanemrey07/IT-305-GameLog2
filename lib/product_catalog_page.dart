import 'package:flutter/material.dart';
import 'package:gamelog/product_catalog_api.dart';
import 'package:gamelog/product_catalog_model.dart';

class ProductCatalogPage extends StatefulWidget {
  const ProductCatalogPage({super.key, this.api = const ProductCatalogApi()});

  final ProductCatalogApi api;

  @override
  State<ProductCatalogPage> createState() => _ProductCatalogPageState();
}

class _ProductCatalogPageState extends State<ProductCatalogPage> {
  final _searchController = TextEditingController();
  String _selectedCategory = 'All';
  late Future<List<ProductCatalogItem>> _catalogFuture;

  @override
  void initState() {
    super.initState();
    _catalogFuture = widget.api.fetchCatalog();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _reloadCatalog() {
    setState(() {
      _catalogFuture = widget.api.fetchCatalog();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Catalog'),
        actions: [
          IconButton(
            onPressed: _reloadCatalog,
            tooltip: 'Refresh catalog',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<ProductCatalogItem>>(
        future: _catalogFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Unable to load the GameLog catalog.'),
                    if (snapshot.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        snapshot.error.toString(),
                        textAlign: TextAlign.center,
                      ),
                    ],
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: _reloadCatalog,
                      child: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            );
          }

          final query = _searchController.text.trim().toLowerCase();
          final visibleItems = snapshot.data!
              .where((item) {
                final matchesCategory =
                    _selectedCategory == 'All' ||
                    item.category == _selectedCategory;
                final matchesQuery =
                    query.isEmpty ||
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query) ||
                    item.category.toLowerCase().contains(query);
                return matchesCategory && matchesQuery;
              })
              .toList(growable: false);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'GameLog products and services',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Browse the products, items, and services available in the GameLog app.',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Search products and services',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'All', label: Text('All')),
                  ButtonSegment(value: 'Product', label: Text('Products')),
                  ButtonSegment(value: 'Item', label: Text('Items')),
                  ButtonSegment(value: 'Service', label: Text('Services')),
                ],
                selected: {_selectedCategory},
                onSelectionChanged: (selection) {
                  setState(() => _selectedCategory = selection.first);
                },
              ),
              const SizedBox(height: 16),
              if (visibleItems.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: Text('No products match your search.')),
                )
              else
                ...visibleItems.map((item) => _CatalogCard(item: item)),
            ],
          );
        },
      ),
    );
  }
}

class _CatalogCard extends StatelessWidget {
  const _CatalogCard({required this.item});

  final ProductCatalogItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(child: Icon(_iconFor(item.icon))),
        title: Text(
          item.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(item.description),
        ),
        trailing: Text(
          item.priceLabel,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  IconData _iconFor(String name) {
    switch (name) {
      case 'workspace_premium':
        return Icons.workspace_premium_outlined;
      case 'controller':
        return Icons.sports_esports_outlined;
      case 'insights':
        return Icons.insights_outlined;
      case 'cloud_sync':
        return Icons.cloud_sync_outlined;
      case 'support_agent':
        return Icons.support_agent_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
