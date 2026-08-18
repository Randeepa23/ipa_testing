import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/authentication/presentation/login_controller.dart';
import '../features/authentication/presentation/login_state.dart';
import '../features/chat/presentation/chat_controller.dart';
import '../features/chat/presentation/chat_state.dart';
import '../features/conversations/presentation/conversation_list_controller.dart';
import '../features/conversations/presentation/conversation_list_state.dart';
import '../features/inbox/presentation/inbox_controller.dart';
import '../features/inbox/presentation/inbox_state.dart';
import '../features/notifications/presentation/notifications_controller.dart';
import '../features/profile/presentation/profile_controller.dart';
import '../shared/data/agent_api_client.dart';
import '../shared/data/agent_socket_client.dart';
import '../shared/models/support_models.dart';
import 'routing/app_router.dart';
import 'branding/company_brand.dart';

final agentApiClientProvider = Provider((ref) => AgentApiClient());
final agentSocketClientProvider = Provider((ref) => AgentSocketClient());
final agentSessionProvider = StateProvider<AgentSession?>((ref) => null);
final companyBrandProvider = Provider<CompanyBrand>((ref) {
  return companyBrandForKey(ref.watch(agentSessionProvider)?.brandKey);
});
final currentRepresentativeProvider = Provider<Representative>((ref) {
  final session = ref.watch(agentSessionProvider);
  return Representative(
    id: session?.agentId ?? '',
    name: session?.agentName ?? 'Support agent',
    email: '',
    department: 'Support',
    role: session?.role ?? 'support_agent',
    availabilityStatus: AvailabilityStatus.available,
    profileImageUrl: null,
    permissions: const [],
  );
});
final loginControllerProvider = NotifierProvider<LoginController, LoginState>(
  LoginController.new,
);
final inboxControllerProvider = NotifierProvider<InboxController, InboxState>(
  InboxController.new,
);
final conversationListControllerProvider =
    NotifierProvider<ConversationListController, ConversationListState>(
      ConversationListController.new,
    );
final chatControllerProvider =
    StateNotifierProvider.family<ChatController, ChatState, String>(
      (ref, id) => ChatController(ref, id),
    );
final notificationsControllerProvider =
    NotifierProvider<NotificationsController, NotificationsState>(
      NotificationsController.new,
    );
final profileControllerProvider =
    NotifierProvider<ProfileController, ProfileState>(ProfileController.new);
final appRouterProvider = Provider((ref) => createAppRouter(ref));
