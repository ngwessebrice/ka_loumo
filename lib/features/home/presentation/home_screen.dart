import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/product_model.dart';
import '../../../services/product_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService service = ProductService();

  String selectedCategory = "all"; // ✅ use stable keys
  String searchQuery = "";
  final TextEditingController searchCtrl = TextEditingController();

  void changeCategory(String catKey) {
    setState(() => selectedCategory = catKey);
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }

  // ✅ Map UI category key -> stored Firestore category (EN)
  // If your Firestore category values are exactly "Phones/Fashion/Cars/Electronics"
  // keep this mapping like this.
  String _dbCategoryForKey(String key) {
    switch (key) {
      case "phones":
        return "Phones";
      case "fashion":
        return "Fashion";
      case "cars":
        return "Cars";
      case "electronics":
        return "Electronics";
      default:
        return "All";
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0,
        title: Text(
          "Ka-Loumo",
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: colors.primary),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔍 SEARCH BAR
            Container(
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(14),
              ),
              child: TextField(
                controller: searchCtrl,
                onChanged: (v) => setState(() => searchQuery = v),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search, color: colors.primary),
                  hintText: l10n.searchProducts,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// 🔥 CATEGORY CHIPS
            SizedBox(
              height: 45,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _Chip(
                    l10n.catAll,
                    active: selectedCategory == "all",
                    onTap: () => changeCategory("all"),
                  ),
                  _Chip(
                    l10n.catPhones,
                    active: selectedCategory == "phones",
                    onTap: () => changeCategory("phones"),
                  ),
                  _Chip(
                    l10n.catFashion,
                    active: selectedCategory == "fashion",
                    onTap: () => changeCategory("fashion"),
                  ),
                  _Chip(
                    l10n.catCars,
                    active: selectedCategory == "cars",
                    onTap: () => changeCategory("cars"),
                  ),
                  _Chip(
                    l10n.catElectronics,
                    active: selectedCategory == "electronics",
                    onTap: () => changeCategory("electronics"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            Text(
              l10n.popularItems,
              style: text.titleLarge?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            /// 🔥 PRODUCT GRID
            StreamBuilder<List<ProductModel>>(
              stream: service.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 40),
                      child: CircularProgressIndicator(color: colors.primary),
                    ),
                  );
                }

                List<ProductModel> products = snapshot.data!;

                // Filter category
                if (selectedCategory != "all") {
                  final dbCat = _dbCategoryForKey(selectedCategory);
                  products = products.where((p) => p.category == dbCat).toList();
                }

                // Filter search
                if (searchQuery.isNotEmpty) {
                  final q = searchQuery.toLowerCase();
                  products = products
                      .where((p) => p.title.toLowerCase().contains(q))
                      .toList();
                }

                if (products.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(child: Text(l10n.noProductsFound)),
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.76,
                  ),
                  itemBuilder: (_, i) {
                    final p = products[i];

                    return InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => context.push("/product/${p.id}"),
                      child: ProductCardModel(p: p),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// ================= CATEGORY CHIP =================
class _Chip extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _Chip(
      this.text, {
        required this.onTap,
        this.active = false,
      });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: active ? colors.primary : colors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: textTheme.bodyMedium?.copyWith(
            color: active ? colors.onPrimary : colors.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// ================= PRODUCT CARD =================
class ProductCardModel extends StatelessWidget {
  final ProductModel p;
  const ProductCardModel({super.key, required this.p});

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

    final image = p.images.isNotEmpty ? p.images.first : null;

    return Container(
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
          // ================= IMAGE =================
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

                // Condition / New badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: _Pill(
                    label: p.condition.isNotEmpty ? p.condition : l10n.badgeNew,
                  ),
                ),

                // Image count
                if (p.images.length > 1)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _Pill(label: "1/${p.images.length}"),
                  ),

                // Price chip
                Positioned(
                  bottom: 10,
                  left: 10,
                  child: _PriceChip(price: _formatPrice(p.price)),
                ),

                // SOLD overlay
                if (p.isSold)
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

          // ================= INFO =================
          SizedBox(
            height: 70,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    p.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: text.titleSmall?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 6),
                  if (p.location.isNotEmpty)
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            size: 14, color: colors.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            p.location,
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
    );
  }
}

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
