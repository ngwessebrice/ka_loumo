import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../l10n/app_localizations.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final TextEditingController _searchController = TextEditingController();

  // ✅ stable internal key (NOT translated text)
  String selectedKey = "all";

  // ✅ stable list of internal keys
  final List<String> categoryKeys = const [
    "all",
    "phones",
    "fashion",
    "cars",
    "realestate",
    "electronics",
  ];

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_applyFilters);
    _loadProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ✅ Map UI key -> Firestore stored category
  String _dbCategoryForKey(String key) {
    switch (key) {
      case "phones":
        return "Phones";
      case "fashion":
        return "Fashion";
      case "cars":
        return "Cars";
      case "realestate":
        return "Real Estate";
      case "electronics":
        return "Electronics";
      default:
        return "All";
    }
  }

  // ✅ Map UI key -> localized label
  String _labelForKey(AppLocalizations l10n, String key) {
    switch (key) {
      case "phones":
        return l10n.catPhones;
      case "fashion":
        return l10n.catFashion;
      case "cars":
        return l10n.catCars;
      case "realestate":
        return l10n.catRealEstate;
      case "electronics":
        return l10n.catElectronics;
      default:
        return l10n.catAll;
    }
  }

  void _loadProducts() {
    FirebaseFirestore.instance.collection("products").snapshots().listen((snap) {
      allProducts = snap.docs.map((d) {
        final m = d.data();
        return {
          ...m,
          "id": m["id"] ?? d.id, // ✅ ensure id
        };
      }).toList();
      _applyFilters();
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim().toLowerCase();
    List<Map<String, dynamic>> results = List.from(allProducts);

    if (selectedKey != "all") {
      final dbCat = _dbCategoryForKey(selectedKey);
      results = results.where((p) => p["category"] == dbCat).toList();
    }

    if (query.isNotEmpty) {
      results = results.where((p) {
        final title = p["title"]?.toString().toLowerCase() ?? "";
        final desc = p["description"]?.toString().toLowerCase() ?? "";
        return title.contains(query) || desc.contains(query);
      }).toList();
    }

    setState(() => filteredProducts = results);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        title: Text(
          l10n.explore,
          style: text.titleLarge?.copyWith(color: colors.onSurface),
        ),
        backgroundColor: colors.background,
        elevation: 0.3,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
            child: TextField(
              controller: _searchController,
              style: text.bodyLarge?.copyWith(color: colors.onSurface),
              decoration: InputDecoration(
                hintText: l10n.searchProducts,
                hintStyle: text.bodyMedium?.copyWith(
                  color: colors.onSurface.withOpacity(.6),
                ),
                prefixIcon: Icon(Icons.search, color: colors.onSurface),
                filled: true,
                fillColor: colors.surfaceVariant,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // 🔥 Category chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categoryKeys.length,
              itemBuilder: (c, i) {
                final key = categoryKeys[i];
                final active = key == selectedKey;

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedKey = key);
                    _applyFilters();
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active ? colors.primary : colors.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _labelForKey(l10n, key),
                      style: text.bodyMedium?.copyWith(
                        color: active ? colors.onPrimary : colors.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          // 📦 Products grid
          Expanded(
            child: filteredProducts.isEmpty
                ? Center(
              child: Text(
                l10n.noResults,
                style: text.bodyLarge?.copyWith(color: colors.onSurface),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredProducts.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.76,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (_, i) => ProductCard(data: filteredProducts[i]),
            ),
          )
        ],
      ),
    );
  }
}

///////////////////////////////////////////////////
//              PRODUCT CARD UI (NO HEART)       //
///////////////////////////////////////////////////

class ProductCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ProductCard({super.key, required this.data});

  String _formatPrice(dynamic value) {
    if (value == null) return "—";
    final num? n = value is num ? value : num.tryParse(value.toString());
    if (n == null) return value.toString();

    final s = n.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final List images = (data["images"] is List) ? data["images"] : [];
    final String? image = images.isNotEmpty ? images.first.toString() : null;

    final String id = (data["id"] ?? "").toString();
    final String title = (data["title"] ?? l10n.untitled).toString();
    final String location = (data["location"] ?? "").toString();
    final String condition = (data["condition"] ?? "").toString();
    final bool isSold = data["isSold"] == true;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (id.isEmpty) return;
        context.push('/product/$id');
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 135,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image == null
                      ? Container(
                    color: colors.surfaceVariant,
                    child: Icon(Icons.image_not_supported,
                        color: colors.onSurfaceVariant),
                  )
                      : Image.network(image, fit: BoxFit.cover),

                  Positioned(
                    top: 10,
                    left: 10,
                    child: _Pill(
                      label: condition.isNotEmpty ? condition : l10n.badgeNew,
                    ),
                  ),

                  if (images.length > 1)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _Pill(label: "1/${images.length}"),
                    ),

                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: _PriceChip(price: _formatPrice(data["price"])),
                  ),

                  if (isSold)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(.45),
                        alignment: Alignment.center,
                        child: Text(
                          l10n.sold,
                          style: text.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            SizedBox(
              height: 70,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(Icons.location_on,
                              size: 14, color: colors.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: text.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= HELPER WIDGETS =================

class _Pill extends StatelessWidget {
  final String label;
  const _Pill({required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: text.labelMedium?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _PriceChip extends StatelessWidget {
  final String price;
  const _PriceChip({required this.price});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.95),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        "GNF $price",
        style: text.labelLarge?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
