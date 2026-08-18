import '../../../shared/models/support_models.dart';

enum ChatLoadStatus { loading, loaded, empty, error }

class ChatState {
  const ChatState({
    required this.loadStatus,
    required this.conversation,
    required this.messages,
    required this.messageText,
    required this.isSending,
    required this.connectionState,
    required this.customerTyping,
    required this.customerOnline,
    required this.errorMessage,
    required this.hasOlderMessages,
    required this.isLoadingOlderMessages,
    required this.newMessagesBelowCount,
  });

  const ChatState.initial()
    : loadStatus = ChatLoadStatus.loading,
      conversation = null,
      messages = const [],
      messageText = '',
      isSending = false,
      connectionState = 'Connected',
      customerTyping = false,
      customerOnline = false,
      errorMessage = null,
      hasOlderMessages = false,
      isLoadingOlderMessages = false,
      newMessagesBelowCount = 0;

  final ChatLoadStatus loadStatus;
  final Conversation? conversation;
  final List<ChatMessage> messages;
  final String messageText;
  final bool isSending;
  final String connectionState;
  final bool customerTyping;
  final bool customerOnline;
  final String? errorMessage;
  final bool hasOlderMessages;
  final bool isLoadingOlderMessages;
  final int newMessagesBelowCount;

  bool get isLoading => loadStatus == ChatLoadStatus.loading;

  bool get hasLoadedConversation =>
      loadStatus == ChatLoadStatus.loaded || loadStatus == ChatLoadStatus.empty;

  ChatState copyWith({
    ChatLoadStatus? loadStatus,
    Conversation? conversation,
    List<ChatMessage>? messages,
    String? messageText,
    bool? isSending,
    String? connectionState,
    bool? customerTyping,
    bool? customerOnline,
    String? errorMessage,
    bool? hasOlderMessages,
    bool? isLoadingOlderMessages,
    int? newMessagesBelowCount,
  }) {
    return ChatState(
      loadStatus: loadStatus ?? this.loadStatus,
      conversation: conversation ?? this.conversation,
      messages: messages ?? this.messages,
      messageText: messageText ?? this.messageText,
      isSending: isSending ?? this.isSending,
      connectionState: connectionState ?? this.connectionState,
      customerTyping: customerTyping ?? this.customerTyping,
      customerOnline: customerOnline ?? this.customerOnline,
      errorMessage: errorMessage,
      hasOlderMessages: hasOlderMessages ?? this.hasOlderMessages,
      isLoadingOlderMessages:
          isLoadingOlderMessages ?? this.isLoadingOlderMessages,
      newMessagesBelowCount:
          newMessagesBelowCount ?? this.newMessagesBelowCount,
    );
  }
}
