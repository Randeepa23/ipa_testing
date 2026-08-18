import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../core/config/environment.dart';
import '../models/support_models.dart';

class AgentSession {
  const AgentSession({
    required this.token,
    required this.agentId,
    required this.agentName,
    required this.role,
    required this.brandKey,
  });

  final String token;
  final String agentId;
  final String agentName;
  final String role;
  final String brandKey;
}

class AgentCaseDetail {
  const AgentCaseDetail({required this.conversation, required this.messages});

  final Conversation conversation;
  final List<ChatMessage> messages;
}

class AgentApiClient {
  AgentApiClient({Dio? dio, FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage(),
      _dio = dio ??
          Dio(
            BaseOptions(
              baseUrl: Environment.apiBaseUrl,
              // A missing local backend should be reported promptly instead of
              // leaving the sign-in screen in a loading state.
              connectTimeout: const Duration(seconds: 4),
              sendTimeout: const Duration(seconds: 4),
              receiveTimeout: const Duration(seconds: 8),
            ),
          );

  static const _tokenKey = 'agent_access_token';
  static const _agentIdKey = 'agent_id';
  static const _agentNameKey = 'agent_name';
  static const _roleKey = 'agent_role';
  static const _brandKey = 'agent_brand_key';
  final Dio _dio;
  final FlutterSecureStorage _storage;

  Future<AgentSession?> restoreSession() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null || token.isEmpty) return null;
    return AgentSession(
      token: token,
      agentId: await _storage.read(key: _agentIdKey) ?? '',
      agentName: await _storage.read(key: _agentNameKey) ?? 'Support agent',
      role: await _storage.read(key: _roleKey) ?? 'support_agent',
      brandKey: await _storage.read(key: _brandKey) ?? 'sr',
    );
  }

  Future<AgentSession> login(
    String username,
    String password, {
    bool rememberMe = true,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/agent/auth/login',
      data: {'username': username, 'password': password},
    );
    final data = response.data ?? const <String, dynamic>{};
    final session = AgentSession(
      token: data['access_token'] as String,
      agentId: '${data['agent_id'] ?? ''}',
      agentName: '${data['agent_name'] ?? 'Support agent'}',
      role: '${data['role'] ?? 'support_agent'}',
      brandKey: username.trim().toLowerCase(),
    );
    if (rememberMe) await _saveSession(session);
    return session;
  }

  Future<void> logout() => _storage.deleteAll();

  Future<List<Conversation>> getCases({String? status, int limit = 100}) async {
    final response = await _authorizedGet(
      '/api/agent/cases',
      queryParameters: {'status': ?status, 'page': 1, 'limit': limit},
    );
    final data = response.data as Map<String, dynamic>? ?? const {};
    final values = (data['cases'] as List? ?? const []);
    return values
        .whereType<Map>()
        .map((item) => conversationFromApi(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<AgentCaseDetail> getCase(String caseId) async {
    final response = await _authorizedGet('/api/agent/cases/$caseId');
    final data = response.data as Map<String, dynamic>? ?? const {};
    final caseData = data['case'] is Map
        ? Map<String, dynamic>.from(data['case'] as Map)
        : data;
    final messages = (data['messages'] as List? ?? const [])
        .whereType<Map>()
        .map(
          (item) => chatMessageFromApi(caseId, Map<String, dynamic>.from(item)),
        )
        .toList(growable: false);
    return AgentCaseDetail(
      conversation: conversationFromApi(caseData),
      messages: messages,
    );
  }

  Future<void> acceptCase(String caseId) =>
      _authorizedPost('/api/agent/cases/$caseId/accept');
  Future<void> sendMessage(String caseId, String message) => _authorizedPost(
    '/api/agent/cases/$caseId/messages',
    data: {'message': message},
  );
  Future<void> setTyping(String caseId, bool isTyping) => _authorizedPost(
    '/api/agent/cases/$caseId/typing',
    data: {'is_typing': isTyping},
  );
  Future<void> closeCase(String caseId) =>
      _authorizedPost('/api/agent/cases/$caseId/close');
  Future<void> holdCase(String caseId) =>
      _authorizedPost('/api/agent/cases/$caseId/hold');
  Future<void> resumeCase(String caseId) =>
      _authorizedPost('/api/agent/cases/$caseId/resume');

  Future<Response<dynamic>> _authorizedGet(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: await _authOptions(),
    );
  }

  Future<void> _authorizedPost(String path, {Object? data}) async {
    await _dio.post(path, data: data, options: await _authOptions());
  }

  Future<Options> _authOptions() async {
    final token = await _storage.read(key: _tokenKey);
    return Options(
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  Future<void> _saveSession(AgentSession session) => Future.wait([
    _storage.write(key: _tokenKey, value: session.token),
    _storage.write(key: _agentIdKey, value: session.agentId),
    _storage.write(key: _agentNameKey, value: session.agentName),
    _storage.write(key: _roleKey, value: session.role),
    _storage.write(key: _brandKey, value: session.brandKey),
  ]);
}

Conversation conversationFromApi(Map<String, dynamic> data) {
  final source = '${data['source'] ?? 'chatbot'}';
  final status = _apiStatus('${data['status'] ?? 'waiting'}');
  final created = _apiDate(data['created_at'] ?? data['updated_at']);
  final customerName = data['customer_name'] as String?;
  final customerEmail = data['customer_email'] as String?;
  return Conversation(
    id: '${data['id']}',
    customer: Customer(
      id: '${data['customer_session_id'] ?? data['conversation_id'] ?? data['id']}',
      // Chatbot escalations can also include the customer's name. Showing it
      // gives representatives immediate context instead of a generic label.
      name: customerName,
      phone: '',
      email: customerEmail ?? '',
      language: '${data['language'] ?? ''}',
      websiteSessionId: '${data['customer_session_id'] ?? ''}',
      profileImageUrl: null,
    ),
    bookingSummary: BookingSummary(
      bookingReference: '${data['case_code'] ?? ''}',
      vehicleId: '',
      vehicleName: '${data['reason'] ?? ''}',
      pickupLocation: '',
      returnLocation: '',
      pickupDateTime: created,
      returnDateTime: created,
      status: '',
    ),
    latestMessage: '${data['unresolved_question'] ?? data['reason'] ?? ''}',
    lastMessageAt: _apiDate(data['updated_at'] ?? data['created_at']),
    unreadCount: 0,
    status: status,
    priority: ConversationPriority.normal,
    escalationReason: '${data['reason'] ?? ''}',
    triggerMessageId: '',
    assignedRepresentativeId: data['assigned_agent_id']?.toString(),
    assignedRepresentativeName: null,
    createdAt: created,
    escalatedAt: created,
    acceptedAt: _nullableApiDate(data['accepted_at']),
    // Older deployed API versions do not expose `closed_at`, but set
    // `updated_at` when resolving a case. Use it as the resolved timestamp
    // until the explicit backend field is available.
    resolvedAt: _nullableApiDate(
      data['closed_at'] ??
          (status == ConversationStatus.resolved ? data['updated_at'] : null),
    ),
    customerOnline: false,
    source: source,
    customerName: customerName,
    customerEmail: customerEmail,
    onHold:
        data['on_hold'] == true ||
        data['on_hold'] == 1 ||
        data['on_hold'] == '1',
    heldAt: data['held_at'] as String?,
  );
}

ChatMessage chatMessageFromApi(String caseId, Map<String, dynamic> data) {
  final direction = '${data['direction'] ?? data['sender_type'] ?? ''}';
  final sender =
      direction.contains('agent') ||
          direction.contains('representative') ||
          direction == 'outbound'
      ? SenderType.representative
      : SenderType.customer;
  return ChatMessage(
    id: '${data['id'] ?? data['message_id'] ?? ''}',
    localId: null,
    conversationId: caseId,
    senderType: sender,
    senderId: null,
    senderName: sender == SenderType.representative
        ? 'Support representative'
        : 'Customer',
    content:
        '${data['message'] ?? data['message_text'] ?? data['content'] ?? ''}',
    messageType: 'text',
    createdAt: _apiDate(data['created_at']),
    deliveryStatus: DeliveryStatus.sent,
    isInternalNote: false,
    replyToMessageId: null,
  );
}

ConversationStatus _apiStatus(String status) => switch (status) {
  'waiting' => ConversationStatus.newRequest,
  'active' || 'assigned' => ConversationStatus.assigned,
  'closed' || 'resolved' => ConversationStatus.resolved,
  _ => ConversationStatus.newRequest,
};
DateTime _apiDate(Object? value) => _nullableApiDate(value) ?? DateTime.now();
DateTime? _nullableApiDate(Object? value) =>
    value == null ? null : DateTime.tryParse('$value')?.toLocal();
