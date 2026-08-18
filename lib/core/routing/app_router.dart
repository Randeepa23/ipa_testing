import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/authentication/presentation/login_screen.dart';
import '../../features/chat/presentation/chat_screen.dart';
import '../../features/conversations/presentation/conversation_list_screen.dart';
import '../../features/customers/presentation/customer_details_screen.dart';
import '../../features/customers/presentation/customer_list_screen.dart';
import '../../features/inbox/presentation/inbox_screen.dart';
import '../../features/navigation/presentation/support_shell.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../providers.dart';
import 'app_routes.dart';
import 'navigation_refresh_notifier.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final GlobalKey<NavigatorState> _inboxNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'inbox',
);

final GlobalKey<NavigatorState> _conversationNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'conversations');

final GlobalKey<NavigatorState> _customerNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'customers');

final GlobalKey<NavigatorState> _notificationNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'notifications');

final GlobalKey<NavigatorState> _moreNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'more',
);

GoRouter createAppRouter(Ref ref) {
  final refreshNotifier = NavigationRefreshNotifier();

  ref.listen(loginControllerProvider, (previous, next) {
    if (previous != next) {
      refreshNotifier.refresh();
    }
  });

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final authState = ref.read(loginControllerProvider);

      final onLogin = state.matchedLocation == AppRoutes.login;
      final onSplash = state.matchedLocation == AppRoutes.splash;

      if (authState.isCheckingSession) {
        return onSplash ? null : AppRoutes.splash;
      }

      if (!authState.isAuthenticated) {
        return onLogin ? null : AppRoutes.login;
      }

      if (onLogin || onSplash) {
        return AppRoutes.inbox;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      // Main pages with bottom navigation.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return SupportShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            navigatorKey: _inboxNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.inbox,
                builder: (context, state) {
                  return const InboxScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _conversationNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.conversations,
                builder: (context, state) {
                  return ConversationListScreen(
                    initialStatus: state.uri.queryParameters['status'],
                  );
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _customerNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.customers,
                builder: (context, state) {
                  return const CustomerListScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _notificationNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.notifications,
                builder: (context, state) {
                  return const NotificationsScreen();
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _moreNavigatorKey,
            routes: [
              GoRoute(
                path: AppRoutes.more,
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),

      // Full-screen Chat page outside the bottom navigation shell.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.chat,
        builder: (context, state) {
          final conversationId = state.pathParameters['conversationId'];

          if (conversationId == null || conversationId.trim().isEmpty) {
            return const _InvalidRouteScreen(
              message: 'Conversation ID is missing.',
            );
          }

          debugPrint(
            '[Chat navigation] router received conversationId=$conversationId',
          );
          return ChatScreen(conversationId: conversationId);
        },
      ),

      // Full-screen customer-details page.
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: AppRoutes.customerDetails,
        builder: (context, state) {
          final customerId = state.pathParameters['customerId'];

          if (customerId == null || customerId.trim().isEmpty) {
            return const _InvalidRouteScreen(
              message: 'Customer ID is missing.',
            );
          }

          return CustomerDetailsScreen(customerId: customerId);
        },
      ),
    ],
  );
}

class _InvalidRouteScreen extends StatelessWidget {
  const _InvalidRouteScreen({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(AppRoutes.conversations);
            }
          },
        ),
        title: const Text('Unable to open'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(message, textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
