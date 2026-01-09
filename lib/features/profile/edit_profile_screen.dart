import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../l10n/app_localizations.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  final _picker = ImagePicker();

  String _photoUrl = "";
  File? _newImage;

  bool _loading = true;
  bool _saving = false;
  bool _removePhoto = false;

  User? get _user => FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  void _msg(String t) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t)));
  }

  Future<void> _loadUserData() async {
    try {
      final u = _user;
      if (u == null) {
        setState(() => _loading = false);
        _msg(AppLocalizations.of(context)!.notLoggedIn);
        return;
      }

      final doc = await FirebaseFirestore.instance.collection("users").doc(u.uid).get();
      final data = doc.data();

      if (!mounted) return;

      setState(() {
        _nameCtrl.text = (data?["name"] ?? "").toString();
        _emailCtrl.text = (data?["email"] ?? u.email ?? "").toString();
        _phoneCtrl.text = (data?["phone"] ?? "").toString();
        _bioCtrl.text = (data?["bio"] ?? "").toString();
        _photoUrl = (data?["photoUrl"] ?? "").toString();
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      _msg(AppLocalizations.of(context)!.failedToLoadProfile);
    }
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (img == null || !mounted) return;

    setState(() {
      _newImage = File(img.path);
      _removePhoto = false;
    });
  }

  /// ✅ Upload avatar to: users/<uid>/avatar.jpg
  Future<String> _uploadAvatar(String uid) async {
    if (_newImage == null) return _photoUrl;

    final ref = FirebaseStorage.instance.ref().child("users/$uid/avatar.jpg");

    // overwrite same path (simple). If cache becomes annoying, append ?v=timestamp when displaying.
    await ref.putFile(
      _newImage!,
      SettableMetadata(contentType: "image/jpeg"),
    );

    return await ref.getDownloadURL();
  }

  Future<void> _deleteAvatarIfExists(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child("users/$uid/avatar.jpg");
      await ref.delete();
    } catch (_) {
      // ignore: if file doesn't exist, it's fine
    }
  }

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context)!;

    final u = _user;
    if (u == null) {
      _msg(l10n.notLoggedIn);
      return;
    }

    final uid = u.uid;

    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    final bio = _bioCtrl.text.trim();

    if (name.isEmpty) {
      _msg(l10n.nameRequired);
      return;
    }

    setState(() => _saving = true);

    try {
      String finalPhotoUrl = _photoUrl;

      if (_removePhoto) {
        finalPhotoUrl = "";
        await _deleteAvatarIfExists(uid);
      } else if (_newImage != null) {
        finalPhotoUrl = await _uploadAvatar(uid);
      }

      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "name": name,
        "email": email,
        "phone": phone,
        "bio": bio,
        "photoUrl": finalPhotoUrl,
        "updatedAt": FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;

      setState(() {
        _photoUrl = finalPhotoUrl;
        _newImage = null;
        _saving = false;
      });

      _msg(l10n.profileUpdated);
      context.pop();
    } on FirebaseException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);

      // Good message for Storage/Firestore permission issues
      _msg("${l10n.updateFailed("")}\n${e.code}: ${e.message ?? ""}".trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      _msg(l10n.updateFailed(e.toString()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    final ImageProvider? avatarProvider = _newImage != null
        ? FileImage(_newImage!)
        : (_photoUrl.isNotEmpty ? NetworkImage(_photoUrl) : null);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        title: Text(
          l10n.editProfile,
          style: text.titleLarge?.copyWith(color: colors.onSurface),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colors.primary),
          onPressed: () => context.pop(),
        ),
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: colors.primary))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 38,
                    backgroundColor: colors.surface,
                    backgroundImage: avatarProvider,
                    child: avatarProvider == null
                        ? Icon(Icons.person, size: 34, color: colors.onSurface)
                        : null,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.profilePhoto,
                          style: text.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          l10n.profilePhotoHint,
                          style: text.bodySmall?.copyWith(
                            color: colors.onSurface.withOpacity(.65),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _saving ? null : _pickImage,
                              icon: Icon(Icons.photo_library, color: colors.primary),
                              label: Text(
                                l10n.change,
                                style: TextStyle(color: colors.primary),
                              ),
                            ),
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () {
                                setState(() {
                                  _newImage = null;
                                  _photoUrl = "";
                                  _removePhoto = true;
                                });
                              },
                              child: Text(
                                l10n.remove,
                                style: TextStyle(color: colors.error),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            _inputField(
              label: l10n.fullName,
              controller: _nameCtrl,
              colors: colors,
              text: text,
              icon: Icons.person_outline,
            ),
            _inputField(
              label: l10n.email,
              controller: _emailCtrl,
              colors: colors,
              text: text,
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
            ),
            _inputField(
              label: l10n.phoneNumber,
              controller: _phoneCtrl,
              colors: colors,
              text: text,
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
            ),
            _inputField(
              label: l10n.bio,
              controller: _bioCtrl,
              colors: colors,
              text: text,
              icon: Icons.info_outline,
              maxLines: 3,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saving ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.onPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _saving
                    ? SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
                    : Text(
                  l10n.saveChanges,
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    required ColorScheme colors,
    required TextTheme text,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        readOnly: readOnly,
        keyboardType: keyboard,
        maxLines: maxLines,
        style: text.bodyLarge?.copyWith(color: colors.onSurface),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: colors.primary),
          filled: true,
          fillColor: colors.surfaceVariant,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: colors.primary, width: 2),
          ),
        ),
      ),
    );
  }
}
