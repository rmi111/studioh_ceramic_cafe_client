class Voucher {
  final String code;
  final String type;
  final String value;
  final String description;
  final int expiryDate;
  final bool isActive;
  final int? redeemedDate;

  Voucher({
    required this.code,
    required this.type,
    required this.value,
    required this.description,
    required this.expiryDate,
    required this.isActive,
    this.redeemedDate,
  });

  // Convert a Voucher instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'code': code,
      'type': type,
      'value': value,
      'description': description,
      'expiryDate': expiryDate,
      'isActive': isActive,
      'redeemedDate': redeemedDate,
    };
  }

  // Create Voucher from a Map (handles int, double, String, DateTime)
  factory Voucher.fromMap(Map<String, dynamic> map) {
    int _parseToMillis(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is double) return v.toInt();
      if (v is DateTime) return v.millisecondsSinceEpoch;
      if (v is String) {
        // try parse as int first, then DateTime
        final asInt = int.tryParse(v);
        if (asInt != null) return asInt;
        final asDate = DateTime.tryParse(v);
        if (asDate != null) return asDate.millisecondsSinceEpoch;
        return 0;
      }
      return 0;
    }

    final expiryMillis = _parseToMillis(map['expiryDate']);
    final redeemedMillis =
        map['redeemedDate'] != null
            ? _parseToMillis(map['redeemedDate'])
            : null;

    return Voucher(
      code: map['code']?.toString() ?? '',
      type: map['type']?.toString() ?? '',
      value: map['value']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      expiryDate: expiryMillis,
      isActive:
          map['isActive'] is bool
              ? map['isActive']
              : (map['isActive']?.toString().toLowerCase() == 'true'),
      redeemedDate: redeemedMillis,
    );
  }
  // Create a Voucher instance from a Map
  // factory Voucher.fromMap(Map<String, dynamic> map) {
  //   return Voucher(
  //     code: map['code'] as String,
  //     type: map['type'] as String,
  //     value: map['value'] as String,
  //     description: map['description'] as String,
  //     expiryDate: map['expiryDate'] as int,
  //     isActive: map['isActive'] as bool,
  //     redeemedDate: map['redeemedDate'] as int?,
  //   );
  // }

  Voucher copyWith({
    String? code,
    String? type,
    String? value,
    String? description,
    int? expiryDate,
    bool? isActive,
    int? redeemedDate,
  }) {
    return Voucher(
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      description: description ?? this.description,
      expiryDate: expiryDate ?? this.expiryDate,
      isActive: isActive ?? this.isActive,
      redeemedDate: redeemedDate ?? this.redeemedDate,
    );
  }
}
