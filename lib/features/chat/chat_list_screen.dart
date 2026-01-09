import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../core/services/chat_service.dart';
import '../../l10n/app_localizations.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final chatService = ChatService();
    final colors = Theme.of(context).colorScheme;
    final myUid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.messages),
        elevation: 0.3,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: chatService.getUserChats(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snap.hasError) {
            return Center(child: Text(l10n.failedToLoadChats));
          }

          final chats = snap.data?.docs ?? [];

          // ✅ Hide chats that are hiddenFor me
          final visibleChats = chats.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final hiddenFor = (data['hiddenFor'] as List?)?.cast<String>() ?? [];
            return !hiddenFor.contains(myUid);
          }).toList();

          if (visibleChats.isEmpty) {
            return Center(child: Text(l10n.noConversationsYet));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visibleChats.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, i) {
              final chat = visibleChats[i];
              final data = chat.data() as Map<String, dynamic>;

              return Dismissible(
                key: ValueKey(chat.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 18),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                confirmDismiss: (_) async {
                  return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(l10n.deleteConversationTitle),
                      content: Text(l10n.deleteConversationBody),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.cancel),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.delete),
                        ),
                      ],
                    ),
                  ) ??
                      false;
                },
                onDismissed: (_) async {
                  await chatService.hideChatForMe(chat.id);
                },
                child: _ChatTile(
                  chatId: chat.id,
                  chatData: data,
                  colors: colors,
                  onTap: () => context.push('/chat/${chat.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatTile extends StatelessWidget {
  final String chatId;
  final Map<String, dynamic> chatData;
  final ColorScheme colors;
  final VoidCallback onTap;

  const _ChatTile({
    required this.chatId,
    required this.chatData,
    required this.colors,
    required this.onTap,
  });

  DateTime? _toDate(dynamic v) {
    if (v == null) return null;
    if (v is Timestamp) return v.toDate();
    if (v is DateTime) return v;
    return null;
  }

  String _timeAgo(BuildContext context, DateTime date) {
    final l10n = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(date);

    if (diff.inSeconds < 60) return l10n.timeNow;
    if (diff.inMinutes < 60) return "${diff.inMinutes}m";
    if (diff.inHours < 24) return "${diff.inHours}h";
    if (diff.inDays < 7) return "${diff.inDays}d";

    final weeks = (diff.inDays / 7).floor();
    if (weeks < 4) return "${weeks}w";

    final months = (diff.inDays / 30).floor();
    if (months < 12) return "${months}mo";

    final years = (diff.inDays / 365).floor();
    return "${years}y";
  }

  bool _isUnread(String myUid) {
    final lastSenderId = (chatData['lastSenderId'] ?? "").toString();
    if (lastSenderId.isEmpty) return false;

    if (lastSenderId == myUid) return false;

    final lastReadMap = chatData['lastRead'];
    final DateTime? lastReadAt = (lastReadMap is Map && lastReadMap[myUid] != null)
        ? _toDate(lastReadMap[myUid])
        : null;

    final DateTime? lastMsgAt =
        _toDate(chatData['lastMessageAt']) ?? _toDate(chatData['updatedAt']);

    if (lastReadAt == null || lastMsgAt == null) {
      return true;
    }

    return lastReadAt.isBefore(lastMsgAt);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final myUid = FirebaseAuth.instance.currentUser!.uid;

    final participants = (chatData['participants'] as List).cast<String>();
    final otherUid = participants.firstWhere((u) => u != myUid);
    final productId = chatData['productId'];
    final lastMessage = (chatData['lastMessage'] ?? "").toString();

    final DateTime? updatedAt = _toDate(chatData['updatedAt']);
    final String timeLabel = updatedAt == null ? "" : _timeAgo(context, updatedAt);

    final bool unread = _isUnread(myUid);

    return FutureBuilder<List<DocumentSnapshot>>(
      future: Future.wait([
        FirebaseFirestore.instance.collection('users').doc(otherUid).get(),
        FirebaseFirestore.instance.collection('products').doc(productId).get(),
      ]),
      builder: (context, snap) {
        if (!snap.hasData) {
          return const SizedBox(height: 72);
        }

        final userDoc = snap.data![0];
        final productDoc = snap.data![1];

        final user = userDoc.data() as Map<String, dynamic>?;
        final product = productDoc.data() as Map<String, dynamic>?;

        final userName = (user?['name'] ?? l10n.userFallback).toString();
        final productTitle = (product?['title'] ?? l10n.productFallback).toString();

        final productImages = (product?['images'] as List?) ?? [];
        final productImage = productImages.isNotEmpty ? productImages.first : null;

        return ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: productImage != null
                ? Image.network(
              productImage,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
            )
                : Container(
              width: 52,
              height: 52,
              color: colors.surfaceVariant,
              child: Icon(Icons.image, color: colors.primary),
            ),
          ),
          title: Text(
            productTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                userName,
                style: TextStyle(
                  color: colors.primary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                lastMessage.isEmpty ? l10n.noMessagesYet : lastMessage,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: unread ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ],
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (timeLabel.isNotEmpty)
                Text(
                  timeLabel,
                  style: TextStyle(
                    fontSize: 12,
                    color: colors.onSurface.withOpacity(.5),
                  ),
                ),
              const SizedBox(height: 6),
              if (unread)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: colors.onSurface.withOpacity(.35),
                ),
            ],
          ),
        );
      },
    );
  }
}
