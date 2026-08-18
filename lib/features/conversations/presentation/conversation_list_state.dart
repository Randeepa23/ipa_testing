import '../../../shared/models/support_models.dart';

class ConversationListState {
  const ConversationListState({
    required this.isLoading,
    required this.searchQuery,
    required this.selectedStatus,
    required this.conversations,
    required this.errorMessage,
  });

  const ConversationListState.initial()
    : isLoading = false,
      searchQuery = '',
      selectedStatus = null,
      conversations = const [],
      errorMessage = null;

  final bool isLoading;
  final String searchQuery;
  final ConversationStatus? selectedStatus;
  final List<Conversation> conversations;
  final String? errorMessage;

  ConversationListState copyWith({
    bool? isLoading,
    String? searchQuery,
    ConversationStatus? selectedStatus,
    List<Conversation>? conversations,
    String? errorMessage,
  }) {
    return ConversationListState(
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatus: selectedStatus,
      conversations: conversations ?? this.conversations,
      errorMessage: errorMessage,
    );
  }
}
