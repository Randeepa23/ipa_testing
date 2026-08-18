import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers.dart';
import '../../../shared/models/support_models.dart';

class ProfileState {
  const ProfileState({
    required this.representative,
    required this.conversationsHandledToday,
    required this.averageResponseTime,
    required this.notificationPreferences,
  });
  final Representative representative;
  final int conversationsHandledToday;
  final String averageResponseTime;
  final Map<String, bool> notificationPreferences;
  ProfileState copyWith({
    Representative? representative,
    int? conversationsHandledToday,
    String? averageResponseTime,
    Map<String, bool>? notificationPreferences,
  }) => ProfileState(
    representative: representative ?? this.representative,
    conversationsHandledToday:
        conversationsHandledToday ?? this.conversationsHandledToday,
    averageResponseTime: averageResponseTime ?? this.averageResponseTime,
    notificationPreferences:
        notificationPreferences ?? this.notificationPreferences,
  );
}

class ProfileController extends Notifier<ProfileState> {
  @override
  ProfileState build() {
    final rep = ref.watch(currentRepresentativeProvider);
    return ProfileState(
      representative: rep,
      conversationsHandledToday: 0,
      averageResponseTime: 'Unavailable',
      notificationPreferences: const {
        'New support requests': true,
        'Customer replies': true,
        'Transfers': true,
      },
    );
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async => 'Password changes are not available from the support API yet.';
  void updateNotificationPreference(String preference, bool enabled) {
    state = state.copyWith(
      notificationPreferences: {
        ...state.notificationPreferences,
        preference: enabled,
      },
    );
  }
}
