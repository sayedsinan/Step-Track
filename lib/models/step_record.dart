class StepRecord {
  final DateTime timestamp;
  final int count;
  final String id;

  StepRecord({
    required this.timestamp,
    required this.count,
    required this.id,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StepRecord &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  StepRecord copyWith({
    DateTime? timestamp,
    int? count,
    String? id,
  }) {
    return StepRecord(
      timestamp: timestamp ?? this.timestamp,
      count: count ?? this.count,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.millisecondsSinceEpoch,
      'count': count,
      'id': id,
    };
  }

  factory StepRecord.fromJson(Map<String, dynamic> json) {
    return StepRecord(
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      count: json['count'] as int,
      id: json['id'] as String,
    );
  }
}