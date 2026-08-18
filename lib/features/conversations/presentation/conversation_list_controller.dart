import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../shared/models/support_models.dart';
import 'conversation_list_state.dart';

final conversationsStreamProvider = StreamProvider.autoDispose<List<Conversation>>((
  ref,
) async* {
  final api = ref.watch(agentApiClientProvider);
  yield await api.getCases();

  // A single case operation can emit several socket events in quick
  // succession. Coalesce them so the app does not download the whole case
  // list repeatedly and block animation frames with unnecessary rebuilds.
  final refreshes = StreamController<void>();
  Timer? debounce;
  final subscription = ref.watch(agentSocketClientProvider).events.listen((event) {
    if (_caseListRefreshEvents.contains(event.name)) {
      debounce?.cancel();
      debounce = Timer(const Duration(milliseconds: 250), () {
        if (!refreshes.isClosed) refreshes.add(null);
      });
    }
  });
  ref.onDispose(() {
    debounce?.cancel();
    subscription.cancel();
    refreshes.close();
  });

  await for (final _ in refreshes.stream) {
    yield await api.getCases();
  }
});

const _caseListRefreshEvents = {
  'support_case_created',
  'support_case_assigned',
  'case_accepted',
  'case_closed',
  'case_held',
  'case_resumed',
};

class ConversationListController extends Notifier<ConversationListState> {
  @override
  ConversationListState build() => const ConversationListState.initial();
  void updateQuery(String value) => state = ConversationListState(
    isLoading: false,
    searchQuery: value,
    selectedStatus: state.selectedStatus,
    conversations: const [],
    errorMessage: null,
  );
  void updateStatus(ConversationStatus? value) => state = ConversationListState(
    isLoading: false,
    searchQuery: state.searchQuery,
    selectedStatus: value,
    conversations: const [],
    errorMessage: null,
  );
  List<Conversation> filterConversations(List<Conversation> items) => items
      .where((item) {
        final agentId = ref.read(agentSessionProvider)?.agentId;
        final match = switch (state.selectedStatus) {
          null => true,
          ConversationStatus.newRequest =>
            item.status == ConversationStatus.newRequest,
          ConversationStatus.assigned =>
            item.status == ConversationStatus.assigned &&
                item.assignedRepresentativeId == agentId &&
                !item.onHold,
          ConversationStatus.waitingForRepresentative =>
            item.status == ConversationStatus.assigned &&
                item.assignedRepresentativeId == agentId &&
                item.onHold,
          ConversationStatus.resolved =>
            item.status == ConversationStatus.resolved,
          final value => item.status == value,
        };
        return match &&
            conversationMatchesQuery(item, state.searchQuery, const []);
      })
      .toList(growable: false);
}
