class Voucher {
  final String code;
  final String type;
  final String value;
  final String description;
  final String? expiryDate; // ISO string from API
  final bool isActive;
  final String? redeemedDate; // ISO string from API
  final int? assignedTo; // user ID from API
  final String? assignedToEmail;
  final String? assignedToName;

  Voucher({
    required this.code,
    required this.type,
    required this.value,
    required this.description,
    this.expiryDate,
    required this.isActive,
    this.redeemedDate,
    this.assignedTo,
    this.assignedToEmail,
    this.assignedToName,
  });

  /// Parse from Laravel API JSON response
  factory Voucher.fromJson(Map<String, dynamic> json) {
    // Handle nested 'voucher' key if present
    final Map<String, dynamic> data = json.containsKey('voucher') 
        ? Map<String, dynamic>.from(json['voucher'] as Map)
        : json;

    String? parseDate(dynamic date) {
      if (date == null) return null;
      if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date).toIso8601String();
      }
      return date.toString();
    }

    return Voucher(
      code: data['code']?.toString() ?? '',
      type: data['type']?.toString() ?? '',
      value: data['value']?.toString() ?? '',
      description: data['description']?.toString() ?? '',
      expiryDate: parseDate(data['expiry_date']),
      isActive: data['is_active'] is bool
          ? data['is_active']
          : (data['is_active']?.toString().toLowerCase() != 'false'), // Default to true if not explicitly false
      redeemedDate: parseDate(data['redeemed_date']),
      assignedTo: data['assigned_to'] is int ? data['assigned_to'] : null,
      assignedToEmail: data['assigned_to_email']?.toString(),
      assignedToName: data['assigned_to_name']?.toString(),
    );
  }

  /// Helper to check if voucher has been redeemed
  bool get isRedeemed => redeemedDate != null;

  /// Helper to check if voucher is expired
  bool get isExpired {
    if (expiryDate == null) return false;
    try {
      final expiry = DateTime.parse(expiryDate!);
      return expiry.isBefore(DateTime.now());
    } catch (_) {
      return false;
    }
  }

  /// Parse expiry date as DateTime
  DateTime? get expiryDateTime {
    if (expiryDate == null) return null;
    try {
      return DateTime.parse(expiryDate!);
    } catch (_) {
      return null;
    }
  }

  /// Parse redeemed date as DateTime
  DateTime? get redeemedDateTime {
    if (redeemedDate == null) return null;
    try {
      return DateTime.parse(redeemedDate!);
    } catch (_) {
      return null;
    }
  }

  Voucher copyWith({
    String? code,
    String? type,
    String? value,
    String? description,
    String? expiryDate,
    bool? isActive,
    String? redeemedDate,
    int? assignedTo,
    String? assignedToEmail,
    String? assignedToName,
    bool clearAssignment = false,
  }) {
    return Voucher(
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      redeemedDate: redeemedDate ?? this.redeemedDate,
      assignedTo: clearAssignment ? null : (assignedTo ?? this.assignedTo),
      assignedToEmail: clearAssignment
          ? null
          : (assignedToEmail ?? this.assignedToEmail),
      assignedToName: clearAssignment
          ? null
          : (assignedToName ?? this.assignedToName),
    );
  }
}
