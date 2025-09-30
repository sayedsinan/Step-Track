class HRRecord {
  final DateTime timestamp;
  final int bpm;
  final String id;

  HRRecord({
    required this.timestamp,
    required this.bpm,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HRRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  HRRecord copyWith({
    DateTime? timestamp,
    int? bpm,
    String? id,
  }) {
    return HRRecord(
      timestamp: timestamp ?? this.timestamp,
      bpm: bpm ?? this.bpm,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'bpm': bpm,
      'id': id,
    };
  }

  factory HRRecord.fromJson(Map<String, dynamic> json) {
    return HRRecord(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      bpm: json['bpm'] as int,
      id: json['id'] as String,
    );
  }
}