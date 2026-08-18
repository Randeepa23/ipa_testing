import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../shared/models/support_models.dart';
import '../../conversations/presentation/conversation_list_controller.dart';
import 'inbox_state.dart';

class InboxController extends Notifier<InboxState> {
  @override
  InboxState build() {
    ref.listen(conversationsStreamProvider, (_, next) {
      next.when(
        data: _updateFromCases,
        loading: () => state = state.copyWith(isLoading: true),
        error: (error, _) {
          // A 401 is not an offline condition. It means the saved token is
          // missing or expired; clear it so the router returns to sign-in
          // instead of leaving the user on an empty, misleading dashboard.
          if (error is DioException && error.response?.statusCode == 401) {
            ref.read(loginControllerProvider.notifier).signOut();
            return;
          }

          state = state.copyWith(
            isLoading: false,
            isOffline: true,
            errorMessage: 'Couldn\'t load inbox.',
          );
        },
      );
    }, fireImmediately: true);
    return const InboxState.initial();
  }

  Future<void> refresh() async {
    if (state.isRefreshing) return;
    state = state.copyWith(isRefreshing: true, errorMessage: null);
    try {
      ref.invalidate(conversationsStreamProvider);
      await ref.read(conversationsStreamProvider.future);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        isRefreshing: false,
        isOffline: true,
        errorMessage: 'Couldn\'t load inbox.',
      );
    }
  }

  void _updateFromCases(List<Conversation> cases) {
    final agentId = ref.read(agentSessionProvider)?.agentId;
    final today = DateTime.now();
    final resolved = cases.where((c) =>
      c.status == ConversationStatus.resolved &&
      c.resolvedAt?.year == today.year &&
      c.resolvedAt?.month == today.month &&
      c.resolvedAt?.day == today.day,
    ).length;
    state = state.copyWith(
      isLoading: false,
      isRefreshing: false,
      summary: DashboardSummary(
        newRequests: cases.where((c) => c.status == ConversationStatus.newRequest).length,
        assignedToMe: cases.where((c) => c.status == ConversationStatus.assigned && c.assignedRepresentativeId == agentId && !c.onHold).length,
        waiting: cases.where((c) => c.status == ConversationStatus.assigned && c.assignedRepresentativeId == agentId && c.onHold).length,
        resolvedToday: resolved,
      ),
      recentConversations: cases.where((c) => c.status == ConversationStatus.resolved).take(4).toList(),
      isOffline: false,
      errorMessage: null,
    );
  }
}
