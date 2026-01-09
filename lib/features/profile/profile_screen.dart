import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(l10n.logoutTitle),
        content: Text(l10n.logoutBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel, style: TextStyle(color: colors.primary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.error,
              foregroundColor: colors.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.logout),
          ),
        ],
      ),
    ) ??
        false;

    if (!confirmed) return;

    try {
      await FirebaseAuth.instance.signOut();
      if (!context.mounted) return;
      context.go('/login');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.logoutFailed(e.toString()))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final u = FirebaseAuth.instance.currentUser;
    if (u == null) {
      final colors = Theme.of(context).colorScheme;
      return Scaffold(
        backgroundColor: colors.background,
        body: Center(child: Text(l10n.notLoggedIn)),
      );
    }

    final uid = u.uid;

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: colors.background,
        elevation: 0.3,
        title: Text(
          l10n.profile,
          style: text.titleLarge?.copyWith(color: colors.onSurface),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: colors.primary),
            onPressed: () => context.push('/edit-profile'),
            tooltip: l10n.editProfile,
          ),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("users").doc(uid).snapshots(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return Center(child: CircularProgressIndicator(color: colors.primary));
          }

          if (!snap.data!.exists) {
            return Center(
              child: Text(l10n.noProfileFound, style: TextStyle(color: colors.onSurface)),
            );
          }

          final data = snap.data!.data() as Map<String, dynamic>;

          final String name = (data["name"] ?? l10n.unknownUser).toString();
          final String email = (data["email"] ?? "").toString();
          final String phone = (data["phone"] ?? "").toString();
          final String bio = (data["bio"] ?? "").toString();
          final String photoUrl = (data["photoUrl"] ?? "").toString();

          // ⭐ Rating
          final double rating =
          (data['rating'] is num) ? (data['rating'] as num).toDouble() : 0.0;
          final int ratingCount =
          (data['ratingCount'] is num) ? (data['ratingCount'] as num).toInt() : 0;

          // ✅ Plan / limits
          final String plan = (data["plan"] ?? "free").toString(); // free | pro
          final bool isPro = plan.toLowerCase() == "pro";

          final int activeListings =
          (data["activeListings"] is num) ? (data["activeListings"] as num).toInt() : 0;

          final int listingLimit =
          (data["listingLimit"] is num) ? (data["listingLimit"] as num).toInt() : 3;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 15),

                // ============================
                // PROFILE PHOTO
                // ============================
                CircleAvatar(
                  radius: 55,
                  backgroundColor: colors.surface.withOpacity(0.3),
                  backgroundImage: photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                  child: photoUrl.isEmpty
                      ? Icon(Icons.person, size: 55, color: colors.onSurface)
                      : null,
                ),

                const SizedBox(height: 16),

                Text(
                  name,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                // ✅ PRO BADGE
                if (isPro) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colors.primary.withOpacity(.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: colors.primary.withOpacity(.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.workspace_premium, size: 16, color: colors.primary),
                        const SizedBox(width: 6),
                        Text(
                          l10n.pro,
                          style: text.labelMedium?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 6),

                if (email.isNotEmpty)
                  Text(
                    email,
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.7),
                    ),
                  ),
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    phone,
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],

                if (bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    bio,
                    textAlign: TextAlign.center,
                    style: text.bodyMedium?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],

                const SizedBox(height: 30),

                // ============================
                // PROFILE STATS (V1)
                // Listings shows Active / Limit
                // ============================
                Row(
                  children: [
                    Expanded(
                      child: _ProfileStat(
                        title: l10n.listings,
                        value: "$activeListings/$listingLimit",
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ProfileStat(
                        title: l10n.rating,
                        value: rating.toStringAsFixed(1),
                      ),
                    ),
                  ],
                ),

                if (ratingCount > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.ratingCountLabel(ratingCount),
                    style: text.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],

                const SizedBox(height: 35),

                // ============================
                // MENU TILES
                // ============================

                // ✅ Upgrade tile (only show if FREE)
                if (!isPro)
                  _ProfileTile(
                    icon: Icons.workspace_premium,
                    title: l10n.upgradeToPro,
                    onTap: () => context.push('/upgrade'),
                  ),

                _ProfileTile(
                  icon: Icons.shopping_bag,
                  title: l10n.myListings,
                  onTap: () => context.push('/my-listings'),
                ),
                _ProfileTile(
                  icon: Icons.favorite,
                  title: l10n.favorites,
                  onTap: () => context.push('/favorites'),
                ),
                _ProfileTile(
                  icon: Icons.settings,
                  title: l10n.settings,
                  onTap: () => context.push('/settings'),
                ),
                _ProfileTile(
                  icon: Icons.help_outline,
                  title: l10n.helpSupport,
                  onTap: () => context.push('/help'),
                ),

                const SizedBox(height: 28),

                // ============================
                // LOGOUT
                // ============================
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.logout, color: colors.error),
                    label: Text(
                      l10n.logout,
                      style: text.titleMedium?.copyWith(
                        color: colors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colors.error.withOpacity(.45)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => _logout(context),
                  ),
                ),

                const SizedBox(height: 14),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ==============================================
class _ProfileStat extends StatelessWidget {
  final String title, value;
  const _ProfileStat({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: text.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: text.bodyMedium?.copyWith(
              color: colors.onSurface.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}

// ==============================================
class _ProfileTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ProfileTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: colors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        leading: Icon(icon, color: colors.primary),
        title: Text(
          title,
          style: text.bodyLarge?.copyWith(color: colors.onSurface),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: colors.onSurface.withOpacity(0.5),
        ),
        onTap: onTap,
      ),
    );
  }
}
