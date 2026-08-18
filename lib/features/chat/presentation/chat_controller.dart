import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../shared/data/agent_api_client.dart';
import '../../conversations/presentation/conversation_list_controller.dart';
import 'chat_state.dart';

// A case endpoint already returns both the conversation and its messages.
// Keeping them in one provider avoids two identical requests on every chat
// open and refresh.
final chatCaseProvider = StreamProvider.autoDispose.family<AgentCaseDetail, String>((
  ref,
  id,
) async* {
  final api = ref.watch(agentApiClientProvider);
  yield await api.getCase(id);
  await for (final event in ref.watch(agentSocketClientProvider).events) {
    final data = event.data;
    final eventCaseId = data is Map
        ? '${data['case_id'] ?? data['id'] ?? ''}'
        : '';
    if (_caseRefreshEvents.contains(event.name) && eventCaseId == id) {
      yield await api.getCase(id);
    }
  }
});

class ChatController extends StateNotifier<ChatState> {
  ChatController(this.ref, this._caseId) : super(const ChatState.initial());
  final Ref ref;
  final String _caseId;
  AgentApiClient get _api => ref.read(agentApiClientProvider);
  Future<void> sendMessage(String draft, {bool internalNote = false}) async {
    final text = draft.trim();
    if (text.isEmpty || state.isSending) return;
    state = state.copyWith(isSending: true, errorMessage: null);
    try {
      await _api.sendMessage(_caseId, text);
      state = state.copyWith(isSending: false, messageText: '');
      _refreshCaseViews();
    } catch (_) {
      state = state.copyWith(
        isSending: false,
        errorMessage: "Couldn't send this message. Please try again.",
      );
    }
  }

  Future<void> acceptConversation() async {
    try {
      await _api.acceptCase(_caseId);
      _refreshCaseViews();
    } catch (_) {
      state = state.copyWith(
        errorMessage: "Couldn't accept this request. Please try again.",
      );
    }
  }

  Future<void> resolveConversation() async {
    try {
      await _api.closeCase(_caseId);
      _refreshCaseViews();
    } catch (_) {
      state = state.copyWith(
        errorMessage: "Couldn't close this request. Please try again.",
      );
    }
  }

  Future<bool> holdConversation() async {
    try {
      await _api.holdCase(_caseId);
      _refreshCaseViews();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: "Couldn't put this case on hold.");
      return false;
    }
  }

  Future<bool> resumeConversation() async {
    try {
      await _api.resumeCase(_caseId);
      _refreshCaseViews();
      return true;
    } catch (_) {
      state = state.copyWith(errorMessage: "Couldn't resume this case.");
      return false;
    }
  }

  Future<void> reopenConversation() async => state = state.copyWith(
    errorMessage: 'Reopening cases is not available from the support API yet.',
  );
  void clearError() => state = state.copyWith(errorMessage: null);

  void _refreshCaseViews() {
    ref.invalidate(chatCaseProvider(_caseId));
    // This is one shared refresh: inbox, conversations, customers, and
    // notifications all consume the same result rather than fetching it each.
    ref.invalidate(conversationsStreamProvider);
  }
}

const _caseRefreshEvents = {
  'support_customer_message',
  'case_accepted',
  'case_closed',
  'case_held',
  'case_resumed',
};
