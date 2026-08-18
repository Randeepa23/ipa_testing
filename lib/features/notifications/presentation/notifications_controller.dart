import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/support_models.dart';
import '../../conversations/presentation/conversation_list_controller.dart';

class NotificationsState {
  const NotificationsState({
    required this.isLoading,
    required this.items,
    required this.errorMessage,
  });
  const NotificationsState.initial()
    : isLoading = false,
      items = const [],
      errorMessage = null;
  final bool isLoading;
  final List<NotificationItem> items;
  final String? errorMessage;
}

class NotificationsController extends Notifier<NotificationsState> {
  @override
  NotificationsState build() {
    ref.listen(conversationsStreamProvider, (_, next) {
      next.when(
        data: _load,
        loading: () => state = NotificationsState(
          isLoading: true,
          items: state.items,
          errorMessage: null,
        ),
        error: (_, _) => state = const NotificationsState.initial(),
      );
    }, fireImmediately: true);
    return const NotificationsState.initial();
  }

  void _load(List<Conversation> cases) {
    state = NotificationsState(
      isLoading: false,
      errorMessage: null,
      items: cases
          .where((c) => c.status == ConversationStatus.newRequest)
          .map(
            (c) => NotificationItem(
              id: c.id,
              type: NotificationType.newSupportRequest,
              title: 'New support request',
              body: c.latestMessage,
              conversationId: c.id,
              isRead: false,
              createdAt: c.createdAt,
            ),
          )
          .toList(),
    );
  }

  Future<void> markAllRead() async {
    state = NotificationsState(
      isLoading: false,
      errorMessage: null,
      items: state.items
          .map(
            (item) => NotificationItem(
              id: item.id,
              type: item.type,
              title: item.title,
              body: item.body,
              conversationId: item.conversationId,
              isRead: true,
              createdAt: item.createdAt,
            ),
          )
          .toList(),
    );
  }
}
