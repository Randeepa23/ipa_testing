import 'package:flutter/foundation.dart';

enum ConversationStatus {
  botActive,
  newRequest,
  unassigned,
  waitingForRepresentative,
  assigned,
  waitingForCustomer,
  representativeReplied,
  resolved,
  closed,
  reopened,
}

enum ConversationPriority { low, normal, high, urgent }

enum SenderType { customer, chatbot, representative, system }

enum DeliveryStatus { pending, sent, delivered, read, failed }

enum NotificationType {
  newSupportRequest,
  customerReplied,
  conversationAssigned,
  conversationTransferred,
  representativeMentioned,
  conversationResolved,
  conversationReopened,
  waitingTimeWarning,
}

enum AvailabilityStatus { available, busy, offline }

class Representative {
  const Representative({
    required this.id,
    required this.name,
    required this.email,
    required this.department,
    required this.role,
    required this.availabilityStatus,
    required this.profileImageUrl,
    required this.permissions,
  });

  final String id;
  final String name;
  final String email;
  final String department;
  final String role;
  final AvailabilityStatus availabilityStatus;
  final String? profileImageUrl;
  final List<String> permissions;
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.language,
    required this.websiteSessionId,
    required this.profileImageUrl,
  });

  final String id;
  final String? name;
  final String phone;
  final String email;
  final String language;
  final String websiteSessionId;
  final String? profileImageUrl;

  String get displayName =>
      (name == null || name!.trim().isEmpty) ? 'Guest Customer' : name!;
}

class BookingSummary {
  const BookingSummary({
    required this.bookingReference,
    required this.vehicleId,
    required this.vehicleName,
    required this.pickupLocation,
    required this.returnLocation,
    required this.pickupDateTime,
    required this.returnDateTime,
    required this.status,
  });

  final String bookingReference;
  final String vehicleId;
  final String vehicleName;
  final String pickupLocation;
  final String returnLocation;
  final DateTime pickupDateTime;
  final DateTime returnDateTime;
  final String status;
}

class Conversation {
  const Conversation({
    required this.id,
    required this.customer,
    required this.bookingSummary,
    required this.latestMessage,
    required this.lastMessageAt,
    required this.unreadCount,
    required this.status,
    required this.priority,
    required this.escalationReason,
    required this.triggerMessageId,
    required this.assignedRepresentativeId,
    required this.assignedRepresentativeName,
    required this.createdAt,
    required this.escalatedAt,
    required this.acceptedAt,
    required this.resolvedAt,
    required this.customerOnline,
    this.source = 'chatbot',
    this.customerName,
    this.customerEmail,
    this.onHold = false,
    this.heldAt,
  });

  final String id;
  final Customer customer;
  final BookingSummary bookingSummary;
  final String latestMessage;
  final DateTime lastMessageAt;
  final int unreadCount;
  final ConversationStatus status;
  final ConversationPriority priority;
  final String escalationReason;
  final String triggerMessageId;
  final String? assignedRepresentativeId;
  final String? assignedRepresentativeName;
  final DateTime createdAt;
  final DateTime? escalatedAt;
  final DateTime? acceptedAt;
  final DateTime? resolvedAt;
  final bool customerOnline;
  final String source;
  final String? customerName;
  final String? customerEmail;
  final bool onHold;
  final String? heldAt;

  bool get isWebsiteInquiry => source == 'website_inquiry';

  String get displayName {
    final websiteName = customerName?.trim() ?? '';
    return isWebsiteInquiry && websiteName.isNotEmpty
        ? websiteName
        : customer.displayName;
  }

  String? get displayEmail {
    final websiteEmail = customerEmail?.trim() ?? '';
    return isWebsiteInquiry && websiteEmail.isNotEmpty ? websiteEmail : null;
  }
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.localId,
    required this.conversationId,
    required this.senderType,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.messageType,
    required this.createdAt,
    required this.deliveryStatus,
    required this.isInternalNote,
    required this.replyToMessageId,
  });

  final String id;
  final String? localId;
  final String conversationId;
  final SenderType senderType;
  final String? senderId;
  final String senderName;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final DeliveryStatus deliveryStatus;
  final bool isInternalNote;
  final String? replyToMessageId;
}

class NotificationItem {
  const NotificationItem({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.conversationId,
    required this.isRead,
    required this.createdAt,
  });

  final String id;
  final NotificationType type;
  final String title;
  final String body;
  final String? conversationId;
  final bool isRead;
  final DateTime createdAt;
}

class SavedResponse {
  const SavedResponse({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
  });

  final String id;
  final String category;
  final String title;
  final String content;
}

class DashboardSummary {
  const DashboardSummary({
    required this.newRequests,
    required this.assignedToMe,
    required this.waiting,
    required this.resolvedToday,
  });

  final int newRequests;
  final int assignedToMe;
  final int waiting;
  final int resolvedToday;
}

bool conversationMatchesQuery(
  Conversation conversation,
  String query,
  List<ChatMessage> messages,
) {
  if (query.isEmpty) {
    return true;
  }
  final lower = query.toLowerCase();
  final customer = conversation.customer;
  final booking = conversation.bookingSummary;
  return conversation.id.toLowerCase().contains(lower) ||
      conversation.displayName.toLowerCase().contains(lower) ||
      customer.phone.toLowerCase().contains(lower) ||
      customer.email.toLowerCase().contains(lower) ||
      booking.bookingReference.toLowerCase().contains(lower) ||
      booking.vehicleName.toLowerCase().contains(lower) ||
      conversation.latestMessage.toLowerCase().contains(lower) ||
      messages.any((message) => message.content.toLowerCase().contains(lower));
}

@visibleForTesting
String conversationStatusLabel(ConversationStatus status) {
  switch (status) {
    case ConversationStatus.botActive:
      return 'Bot active';
    case ConversationStatus.newRequest:
      return 'New';
    case ConversationStatus.unassigned:
      return 'Unassigned';
    case ConversationStatus.waitingForRepresentative:
      return 'Waiting';
    case ConversationStatus.assigned:
      return 'Assigned';
    case ConversationStatus.waitingForCustomer:
      return 'Waiting';
    case ConversationStatus.representativeReplied:
      return 'Replied';
    case ConversationStatus.resolved:
      return 'Resolved';
    case ConversationStatus.closed:
      return 'Closed';
    case ConversationStatus.reopened:
      return 'Reopened';
  }
}
