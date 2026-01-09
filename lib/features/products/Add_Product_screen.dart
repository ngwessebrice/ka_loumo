import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/product_service.dart';
import '../../l10n/app_localizations.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final service = ProductService();
  final picker = ImagePicker();

  final titleCtrl = TextEditingController();
  final priceCtrl = TextEditingController();
  final descCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  String category = "Phones";
  String condition = "New";
  String location = "Conakry";

  List<File> images = [];
  bool loading = false;

  @override
  void dispose() {
    titleCtrl.dispose();
    priceCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  // ---------- Helpers ----------
  void msg(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  int _parsePriceToInt(String raw) {
    final cleaned = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }

  String _formatPrice(dynamic value) {
    final n = value is num ? value.toInt() : _parsePriceToInt(value.toString());
    if (n <= 0) return "";
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final posFromEnd = s.length - i;
      buf.write(s[i]);
      if (posFromEnd > 1 && posFromEnd % 3 == 1) buf.write(' ');
    }
    return buf.toString();
  }

  int _maxListingsForPlan(String plan) {
    final p = plan.trim().toLowerCase();
    if (p == "pro") return 20;
    return 3;
  }

  Future<bool> _canCreateListingOrShowPaywall() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;

    final userRef = FirebaseFirestore.instance.collection("users").doc(uid);
    final snap = await userRef.get();
    final data = snap.data() as Map<String, dynamic>? ?? {};

    final plan = (data["plan"] ?? "free").toString();
    final activeListings = (data["activeListings"] is num)
        ? (data["activeListings"] as num).toInt()
        : 0;

    final maxAllowed = _maxListingsForPlan(plan);

    if (activeListings >= maxAllowed) {
      if (!mounted) return false;
      await showDialog(
        context: context,
        builder: (_) {
          final colors = Theme.of(context).colorScheme;
          final text = Theme.of(context).textTheme;
          final l10n = AppLocalizations.of(context)!;

          return AlertDialog(
            title: Text(
              l10n.listingLimitReached,
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            content: Text(
              plan.toLowerCase() == "pro"
                  ? "${l10n.proLimitReached} ($maxAllowed)"
                  : "${l10n.freeLimitReached} ($maxAllowed)\n${l10n.upgradeToPro}",
              style: text.bodyMedium?.copyWith(
                color: colors.onSurface.withOpacity(.75),
                height: 1.35,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  l10n.ok,
                  style: TextStyle(
                    color: colors.onSurface.withOpacity(.75),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (plan.toLowerCase() != "pro")
                ElevatedButton(
                  onPressed: () {
                    context.push('/upgrade');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                  ),
                  child: Text(l10n.upgrade),
                ),
            ],
          );
        },
      );
      return false;
    }

    return true;
  }

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;

    setState(() {
      images = [...images, ...picked.map((x) => File(x.path))];
      if (images.length > 8) images = images.take(8).toList();
    });
  }

  Future<void> pickFromCamera() async {
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (x == null) return;

    setState(() {
      images = [...images, File(x.path)];
      if (images.length > 8) images = images.take(8).toList();
    });
  }

  void removeImage(int index) {
    setState(() => images.removeAt(index));
  }

  Future<void> uploadProduct() async {
    final l10n = AppLocalizations.of(context)!;

    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (images.isEmpty) {
      msg(l10n.addAtLeastOnePhoto);
      return;
    }

    final priceInt = _parsePriceToInt(priceCtrl.text.trim());
    if (priceInt <= 0) {
      msg(l10n.enterValidPrice);
      return;
    }

    final allowed = await _canCreateListingOrShowPaywall();
    if (!allowed) return;

    setState(() => loading = true);

    final uid = FirebaseAuth.instance.currentUser!.uid;
    final db = FirebaseFirestore.instance;
    final userRef = db.collection("users").doc(uid);

    try {
      await service.createProduct(
        title: titleCtrl.text.trim(),
        description: descCtrl.text.trim(),
        category: category,
        condition: condition,
        location: location,
        price: priceInt,
        ownerId: uid,
        images: images,
        status: "active",
        isBoosted: false,
        boostUntil: null,
      );

      await userRef.set({
        "activeListings": FieldValue.increment(1),
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      msg(l10n.productUploaded);
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      msg("${l10n.uploadFailed}: $e");
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final pricePreview = _formatPrice(priceCtrl.text);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        centerTitle: true,
        title: Text(
          l10n.addProduct,
          style: text.titleLarge?.copyWith(
            color: colors.primary,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: loading ? null : uploadProduct,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: loading
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: colors.onPrimary,
                ),
              )
                  : Text(
                l10n.upload,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
          children: [
            _sectionTitle(l10n.photos, text, colors),
            const SizedBox(height: 10),

            _PhotosPicker(
              images: images,
              onAddGallery: pickImages,
              onAddCamera: pickFromCamera,
              onRemove: removeImage,
            ),

            const SizedBox(height: 18),

            _sectionTitle(l10n.details, text, colors),
            const SizedBox(height: 10),

            _inputField(
              label: l10n.title,
              controller: titleCtrl,
              colors: colors,
              text: text,
              hint: l10n.titleHint,
              validator: (v) {
                final s = (v ?? "").trim();
                if (s.isEmpty) return l10n.titleRequired;
                if (s.length < 3) return l10n.titleTooShort;
                return null;
              },
            ),

            const SizedBox(height: 14),

            _inputField(
              label: l10n.priceGNF,
              controller: priceCtrl,
              colors: colors,
              text: text,
              hint: l10n.priceHint,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (v) {
                final n = _parsePriceToInt(v ?? "");
                if (n <= 0) return l10n.priceRequired;
                return null;
              },
              suffix: pricePreview.isEmpty ? null : "GNF $pricePreview",
            ),

            const SizedBox(height: 14),

            _inputField(
              label: l10n.description,
              controller: descCtrl,
              colors: colors,
              text: text,
              hint: l10n.descriptionHint,
              maxLines: 5,
              validator: (v) {
                final s = (v ?? "").trim();
                if (s.isEmpty) return l10n.descriptionRequired;
                if (s.length < 10) return l10n.descriptionTooShort;
                return null;
              },
            ),

            const SizedBox(height: 18),

            _sectionTitle(l10n.categoryAndLocation, text, colors),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: l10n.category,
                    value: category,
                    onChange: (v) => setState(() => category = v),
                    list: const ["Phones", "Fashion", "Cars", "Electronics", "Home", "Others"],
                    colors: colors,
                    text: text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    label: l10n.condition,
                    value: condition,
                    onChange: (v) => setState(() => condition = v),
                    list: const ["New", "Used"],
                    colors: colors,
                    text: text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _dropdown(
              label: l10n.location,
              value: location,
              onChange: (v) => setState(() => location = v),
              list: const [
                "Conakry",
                "Dixinn",
                "Matam",
                "Ratoma",
                "Kaloum",
                "Coyah",
                "Dubréka",
                "Kindia",
                "Mamou",
                "Labé",
                "Pita",
                "Dalaba",
                "Kankan",
                "Kouroussa",
                "Siguiri",
                "Faranah",
                "Kissidougou",
                "Boké",
                "Fria",
                "Boffa",
                "Gaoual",
                "Nzérékoré",
                "Macenta",
                "Guéckédou",
                "Yomou",
                "Lola",
                "Autre",
              ],

              colors: colors,
              text: text,
            ),

            const SizedBox(height: 6),
            Text(
              l10n.addProductTip,
              style: text.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String textString, TextTheme text, ColorScheme colors) {
    return Text(
      textString,
      style: text.titleMedium?.copyWith(
        fontWeight: FontWeight.w900,
        color: colors.onSurface,
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required ColorScheme colors,
    required TextTheme text,
    String? hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    String? suffix,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: text.bodyLarge?.copyWith(color: colors.onSurface),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: text.bodyMedium?.copyWith(
          color: colors.onSurface.withOpacity(.45),
          fontWeight: FontWeight.w600,
        ),
        labelStyle: text.bodyMedium?.copyWith(
          color: colors.onSurface.withOpacity(.70),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        suffixText: suffix,
        suffixStyle: text.bodyMedium?.copyWith(
          color: colors.primary,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required Function(String) onChange,
    required List<String> list,
    required ColorScheme colors,
    required TextTheme text,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: (v) => onChange(v!),
      items: list
          .map(
            (e) => DropdownMenuItem<String>(
          value: e,
          child: Text(
            e,
            style: text.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      )
          .toList(),
      dropdownColor: colors.surface,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: text.bodyMedium?.copyWith(
          color: colors.onSurface.withOpacity(.70),
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: colors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: colors.outlineVariant),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}

// -------------------- Photos Picker Widget --------------------

class _PhotosPicker extends StatelessWidget {
  final List<File> images;
  final VoidCallback onAddGallery;
  final VoidCallback onAddCamera;
  final void Function(int index) onRemove;

  const _PhotosPicker({
    required this.images,
    required this.onAddGallery,
    required this.onAddCamera,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.addUpTo8Photos,
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                "${images.length}/8",
                style: text.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.55),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView.builder(
            itemCount: (images.length < 8) ? images.length + 1 : images.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemBuilder: (_, i) {
              final canAdd = images.length < 8;

              if (canAdd && i == images.length) {
                return _AddPhotoTile(
                  onGallery: onAddGallery,
                  onCamera: onAddCamera,
                );
              }

              final file = images[i];

              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.file(
                      file,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: InkWell(
                      onTap: () => onRemove(i),
                      borderRadius: BorderRadius.circular(999),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(.45),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          if (images.isEmpty) ...[
            const SizedBox(height: 10),
            Text(
              l10n.coverPhotoTip,
              style: text.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(.55),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AddPhotoTile extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _AddPhotoTile({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: Icon(Icons.photo_library, color: colors.primary),
                      title: Text(l10n.chooseFromGallery),
                      onTap: () {
                        Navigator.pop(context);
                        onGallery();
                      },
                    ),
                    ListTile(
                      leading: Icon(Icons.photo_camera, color: colors.primary),
                      title: Text(l10n.takePhoto),
                      onTap: () {
                        Navigator.pop(context);
                        onCamera();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: colors.primary),
              const SizedBox(height: 4),
              Text(
                l10n.add,
                style: text.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
