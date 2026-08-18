import '../../../shared/models/support_models.dart';

class InboxState {
  const InboxState({
    required this.isLoading,
    required this.isRefreshing,
    required this.summary,
    required this.recentConversations,
    required this.errorMessage,
    required this.isOffline,
  });

  const InboxState.initial()
    : isLoading = true,
      isRefreshing = false,
      summary = const DashboardSummary(
        newRequests: 0,
        assignedToMe: 0,
        waiting: 0,
        resolvedToday: 0,
      ),
      recentConversations = const [],
      errorMessage = null,
      isOffline = false;

  final bool isLoading;
  final bool isRefreshing;
  final DashboardSummary summary;
  final List<Conversation> recentConversations;
  final String? errorMessage;
  final bool isOffline;

  InboxState copyWith({
    bool? isLoading,
    bool? isRefreshing,
    DashboardSummary? summary,
    List<Conversation>? recentConversations,
    String? errorMessage,
    bool? isOffline,
  }) {
    return InboxState(
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      summary: summary ?? this.summary,
      recentConversations: recentConversations ?? this.recentConversations,
      errorMessage: errorMessage,
      isOffline: isOffline ?? this.isOffline,
    );
  }
}
