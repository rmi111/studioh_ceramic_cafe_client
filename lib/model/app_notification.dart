/// A single entry in the in-app notification panel.
///
/// Mirrors GET /api/v1/user-notifications, where `data` carries the payload the
/// backend notification class wrote (always a title and body, plus type-specific
/// fields such as ref_number or code).
class AppNotification {
  final String id;
  final String type;
  final String title;
  final String body;
  final DateTime? readAt;
  final DateTime? createdAt;
  final Map<String, dynamic> data;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.readAt,
    this.createdAt,
    this.data = const {},
  });

  bool get isRead => readAt != null;

  /// Short class name, e.g. "OrderStatusUpdatedNotification", used to pick an icon.
  String get shortType => type.split('\\').last;

  String? get refNumber => data['ref_number'] as String?;

  String? get voucherCode => data['code'] as String?;

  static DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString())?.toLocal();
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final payload = (json['data'] as Map?)?.cast<String, dynamic>() ?? {};

    return AppNotification(
      id: json['id']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      title: payload['title']?.toString() ?? 'Notification',
      body: payload['body']?.toString() ?? '',
      readAt: _parseDate(json['read_at']),
      createdAt: _parseDate(json['created_at']),
      data: payload,
    );
  }
}
