import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProductScreen extends StatefulWidget {
  final String productId;
  final Map<String, dynamic> productData;

  const EditProductScreen({
    super.key,
    required this.productId,
    required this.productData,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final picker = ImagePicker();

  late final TextEditingController titleCtrl;
  late final TextEditingController priceCtrl;
  late final TextEditingController descCtrl;

  late String category;
  late String condition;
  late String location;

  // Existing + new images
  List<String> existingImages = [];
  List<File> newImages = [];

  // Keep original existing images so we can detect which ones were removed
  late final List<String> _originalExistingImages;

  bool saving = false;

  @override
  void initState() {
    super.initState();

    titleCtrl = TextEditingController(text: (widget.productData['title'] ?? "").toString());
    priceCtrl = TextEditingController(text: (widget.productData['price'] ?? "").toString());
    descCtrl = TextEditingController(text: (widget.productData['description'] ?? "").toString());

    category = (widget.productData['category'] ?? "Phones").toString();
    condition = (widget.productData['condition'] ?? "New").toString();
    location = (widget.productData['location'] ?? "Conakry").toString();

    existingImages = List<String>.from(widget.productData['images'] ?? []);
    _originalExistingImages = List<String>.from(existingImages);
  }

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

  Future<void> pickImages() async {
    final picked = await picker.pickMultiImage(imageQuality: 75);
    if (picked.isEmpty) return;

    setState(() {
      newImages = [...newImages, ...picked.map((e) => File(e.path))];
      _enforceMaxImages();
    });
  }

  Future<void> pickFromCamera() async {
    final x = await picker.pickImage(source: ImageSource.camera, imageQuality: 75);
    if (x == null) return;

    setState(() {
      newImages = [...newImages, File(x.path)];
      _enforceMaxImages();
    });
  }

  void _enforceMaxImages() {
    // total images (existing + new) max 8
    final total = existingImages.length + newImages.length;
    if (total <= 8) return;

    final overflow = total - 8;
    if (overflow > 0 && newImages.isNotEmpty) {
      newImages = newImages.take(newImages.length - overflow).toList();
    }
  }

  void removeExisting(String url) {
    setState(() => existingImages.remove(url));
  }

  void removeNew(File file) {
    setState(() => newImages.remove(file));
  }

  // Delete removed images from Storage (best-effort)
  Future<void> _deleteRemovedImagesFromStorage() async {
    final removed = _originalExistingImages.where((u) => !existingImages.contains(u)).toList();
    if (removed.isEmpty) return;

    for (final url in removed) {
      try {
        final ref = FirebaseStorage.instance.refFromURL(url);
        await ref.delete();
      } catch (_) {
        // ignore (could be old bucket, no permission, or already deleted)
      }
    }
  }

  // ---------- Save ----------
  Future<void> save() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    if (existingImages.isEmpty && newImages.isEmpty) {
      msg("Please keep at least 1 photo.");
      return;
    }

    final priceInt = _parsePriceToInt(priceCtrl.text.trim());
    if (priceInt <= 0) {
      msg("Enter a valid price.");
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      msg("You must be logged in.");
      return;
    }

    setState(() => saving = true);

    try {
      final storage = FirebaseStorage.instance;
      final uploadedUrls = <String>[];

      // ✅ IMPORTANT: upload path MUST match your Storage rules:
      // rules allow: /products/<uid>/**
      // so upload to: products/<uid>/<productId>/<file>.jpg
      for (final file in newImages) {
        final ref = storage.ref().child(
          'products/${user.uid}/${widget.productId}/${DateTime.now().millisecondsSinceEpoch}.jpg',
        );

        await ref.putFile(file, SettableMetadata(contentType: "image/jpeg"));
        final url = await ref.getDownloadURL();
        uploadedUrls.add(url);
      }

      // (Optional) delete removed existing images from Storage
      await _deleteRemovedImagesFromStorage();

      await FirebaseFirestore.instance.collection('products').doc(widget.productId).update({
        'title': titleCtrl.text.trim(),
        'price': priceInt,
        'description': descCtrl.text.trim(),
        'category': category,
        'condition': condition,
        'location': location,
        'images': [...existingImages, ...uploadedUrls],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      msg("Saved ✔");
      context.pop();
    } catch (e) {
      msg("Save failed: $e");
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    final pricePreview = _formatPrice(priceCtrl.text);
    final totalCount = (existingImages.length + newImages.length).clamp(0, 8);

    return Scaffold(
      backgroundColor: colors.background,

      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
        centerTitle: true,
        title: Text(
          "Edit Product",
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
            height: 52,
            width: double.infinity,
            child: ElevatedButton(
              onPressed: saving ? null : save,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: saving
                  ? SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.6,
                  color: colors.onPrimary,
                ),
              )
                  : const Text(
                "Save Changes",
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
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
            _sectionTitle("Photos", text, colors),
            const SizedBox(height: 10),

            _PhotoGrid(
              existing: existingImages,
              newFiles: newImages,
              max: 8,
              countLabel: "$totalCount/8",
              onRemoveExisting: removeExisting,
              onRemoveNew: removeNew,
              onAddGallery: pickImages,
              onAddCamera: pickFromCamera,
            ),

            const SizedBox(height: 18),

            _sectionTitle("Details", text, colors),
            const SizedBox(height: 10),

            _inputField(
              label: "Title",
              controller: titleCtrl,
              colors: colors,
              text: text,
              hint: "e.g. iPhone 13 Pro Max",
              validator: (v) {
                final s = (v ?? "").trim();
                if (s.isEmpty) return "Title is required.";
                if (s.length < 3) return "Title is too short.";
                return null;
              },
            ),

            const SizedBox(height: 14),

            _inputField(
              label: "Price (GNF)",
              controller: priceCtrl,
              colors: colors,
              text: text,
              hint: "e.g. 650000",
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(12),
              ],
              validator: (v) {
                final n = _parsePriceToInt(v ?? "");
                if (n <= 0) return "Price is required.";
                return null;
              },
              suffix: pricePreview.isEmpty ? null : "GNF $pricePreview",
            ),

            const SizedBox(height: 14),

            _inputField(
              label: "Description",
              controller: descCtrl,
              colors: colors,
              text: text,
              hint: "State, accessories, defects, reason for sale…",
              maxLines: 5,
              validator: (v) {
                final s = (v ?? "").trim();
                if (s.isEmpty) return "Description is required.";
                if (s.length < 10) return "Description is too short.";
                return null;
              },
            ),

            const SizedBox(height: 18),

            _sectionTitle("Category & Location", text, colors),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _dropdown(
                    label: "Category",
                    value: category,
                    items: const ["Phones", "Electronics", "Fashion", "Cars", "Home", "Others"],
                    onChanged: (v) => setState(() => category = v),
                    colors: colors,
                    text: text,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _dropdown(
                    label: "Condition",
                    value: condition,
                    items: const ["New", "Used"],
                    onChanged: (v) => setState(() => condition = v),
                    colors: colors,
                    text: text,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            _dropdown(
              label: "Location",
              value: location,
              items: const ["Conakry", "Kindia", "Labé", "Kankan", "Nzérékoré", "Other"],
              onChanged: (v) => setState(() => location = v),
              colors: colors,
              text: text,
            ),

            const SizedBox(height: 6),
            Text(
              "Keep at least 1 photo. Better photos = faster sales.",
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

  // ---------- UI ----------
  Widget _sectionTitle(String label, TextTheme text, ColorScheme colors) {
    return Text(
      label,
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
    required List<String> items,
    required void Function(String) onChanged,
    required ColorScheme colors,
    required TextTheme text,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem<String>(
        value: e,
        child: Text(
          e,
          style: text.bodyMedium?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ))
          .toList(),
      onChanged: (v) => onChanged(v!),
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

// -------------------- Photo Grid --------------------

class _PhotoGrid extends StatelessWidget {
  final List<String> existing;
  final List<File> newFiles;
  final int max;
  final String countLabel;

  final void Function(String url) onRemoveExisting;
  final void Function(File file) onRemoveNew;

  final VoidCallback onAddGallery;
  final VoidCallback onAddCamera;

  const _PhotoGrid({
    required this.existing,
    required this.newFiles,
    required this.max,
    required this.countLabel,
    required this.onRemoveExisting,
    required this.onRemoveNew,
    required this.onAddGallery,
    required this.onAddCamera,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    final total = existing.length + newFiles.length;
    final canAdd = total < max;

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
                  "Edit photos (cover = first photo)",
                  style: text.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              Text(
                countLabel,
                style: text.bodySmall?.copyWith(
                  color: colors.onSurface.withOpacity(.55),
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GridView(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            children: [
              for (final url in existing)
                _ImgTile(
                  child: Image.network(url, fit: BoxFit.cover),
                  onRemove: () => onRemoveExisting(url),
                ),

              for (final f in newFiles)
                _ImgTile(
                  child: Image.file(f, fit: BoxFit.cover),
                  onRemove: () => onRemoveNew(f),
                ),

              if (canAdd)
                _AddTile(
                  onGallery: onAddGallery,
                  onCamera: onAddCamera,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ImgTile extends StatelessWidget {
  final Widget child;
  final VoidCallback onRemove;

  const _ImgTile({required this.child, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox.expand(child: child),
        ),
        Positioned(
          top: 6,
          right: 6,
          child: InkWell(
            onTap: onRemove,
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
  }
}

class _AddTile extends StatelessWidget {
  final VoidCallback onGallery;
  final VoidCallback onCamera;

  const _AddTile({required this.onGallery, required this.onCamera});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (_) => SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library, color: colors.primary),
                    title: const Text("Choose from gallery"),
                    onTap: () {
                      Navigator.pop(context);
                      onGallery();
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.photo_camera, color: colors.primary),
                    title: const Text("Take a photo"),
                    onTap: () {
                      Navigator.pop(context);
                      onCamera();
                    },
                  ),
                ],
              ),
            ),
          ),
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
                "Add",
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
