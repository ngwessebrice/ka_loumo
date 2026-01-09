import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ka_loumo/features/home/presentation/explore_screen.dart';
import 'package:ka_loumo/features/home/presentation/main_dashboard.dart';
import 'package:ka_loumo/features/profile/Settings/language_screen.dart';
import 'package:ka_loumo/features/profile/edit_profile_screen.dart';
import 'package:ka_loumo/features/profile/favorites_screen.dart';
import 'package:ka_loumo/features/profile/help_screen.dart';
import 'package:ka_loumo/features/profile/my_listings_screen.dart';

// ==== IMPORT ALL SCREENS ====
import '../../features/auth/screens/reset_success_screen.dart';
import '../../features/chat/chat_list_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/home/presentation/upgrade_cancel_screen.dart';
import '../../features/home/presentation/upgrade_success_screen.dart';
import '../../features/home/upgradeScreen.dart';

import '../../features/products/Add_Product_screen.dart';
import '../../features/products/screens/product_detail_screen.dart';
import '../../features/profile/edit_product_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/public_seller_screen.dart' hide ProductDetailScreen;
import '../../features/profile/settings_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/otp_screen.dart';
import '../screens/splash_screen.dart';
import '../screens/onboarding_screen.dart';
import '../screens/login_screen.dart';
import '../screens/register_screen.dart';


import '../../features/auth/presentation/forgot_password_screen.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

// ==== MAIN ROUTER ====
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/splash',

  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),

    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),

    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),

    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const MainDashboard(),
    ),

    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfileScreen(),
    ),

    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatListScreen(),
    ),

    GoRoute(
      path: '/chat/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return ChatScreen(chatId: id);
      },
    ),

    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => const SettingsScreen(),
    ),

    GoRoute(
      path: '/forgot-password',
      name: 'forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    GoRoute(
      path: '/reset-success',
      name: 'reset-success',
      builder: (context, state) => const ResetSuccessScreen(),
    ),

    GoRoute(
      path: '/explore',
      name: 'explore',
      builder: (context, state) => const ExploreScreen(),
    ),

    GoRoute(
      path: '/add-product',
      name: 'add-product',
      builder: (context, state) => const AddProductScreen(),
    ),

    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final productId = state.pathParameters['id']!;
        return ProductDetailScreen(productId: productId);
      },
    ),

    GoRoute(
      path: '/edit-profile',
      name: 'edit-profile',
      builder: (context, state) => const EditProfileScreen(),
    ),

    GoRoute(
      path: '/my-listings',
      name: 'my-listings',
      builder: (context, state) => const MyListingsScreen(),
    ),

    GoRoute(
        path: '/favorites',
        name: 'favorites',
      builder: (context, state) => const FavoritesScreen(),
    ),

    GoRoute(
      path: '/help',
      name: 'help',
      builder: (context, state) => const HelpSupportScreen(),
    ),


    GoRoute(
      path: '/language',
      name: 'language',
      builder: (context, state) => const LanguageScreen(),
    ),

    GoRoute(
      path: '/otp',
      name: 'otp',
      builder: (context, state) {
        final data = state.extra as Map;
        return OtpScreen(
          verificationId: data["vid"],
          phone: data["phone"],
        );
      },
    ),

    GoRoute(
      path: '/edit-product',
      builder: (context, state) {
        final args = state.extra as Map<String, dynamic>;
        return EditProductScreen(
          productId: args['id'],
          productData: args['data'],
        );
      },
    ),

    GoRoute(
      path: '/seller/:sellerId',
      builder: (context, state) {
        final id = state.pathParameters['sellerId']!;
        return PublicSellerScreen(sellerId: id);
      },
    ),




    GoRoute(
      path: '/messages',
      builder: (context, state) => const ChatListScreen(),
    ),

    GoRoute(
      path: '/chat/:chatId',
      builder: (context, state) {
        final chatId = state.pathParameters['chatId']!;
        return ChatScreen(chatId: chatId);
      },
    ),


    GoRoute(
      path: '/notifications',
      builder: (context, state) => const NotificationsScreen(),
    ),

    GoRoute(
      path: '/upgrade',
      builder: (context, state) => const UpgradeScreen(),
    ),

    GoRoute(
      path: '/upgrade/success',
      builder: (context, state) {
        final sessionId = state.uri.queryParameters['session_id'];
        return UpgradeSuccessScreen(sessionId: sessionId); // best approach
      },
    ),
    GoRoute(
      path: '/upgrade/cancel',
      builder: (context, state) => const UpgradeCancelScreen(),
    ),





  ],
);
