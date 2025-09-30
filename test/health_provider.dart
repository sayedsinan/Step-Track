import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:step_track/models/step_record.dart';
import 'package:step_track/models/hr_record.dart';

void main() {
  group('StepRecord', () {
    test('creates record correctly', () {
      final now = DateTime.now();
      final record = StepRecord(
        timestamp: now,
        count: 100,
        id: 'test_1',
      );

      expect(record.timestamp, now);
      expect(record.count, 100);
      expect(record.id, 'test_1');
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      final record1 = StepRecord(timestamp: now, count: 100, id: 'test_1');
      final record2 = StepRecord(timestamp: now, count: 100, id: 'test_1');
      final record3 = StepRecord(timestamp: now, count: 100, id: 'test_2');

      expect(record1, equals(record2));
      expect(record1, isNot(equals(record3)));
    });

    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final record = StepRecord(timestamp: now, count: 100, id: 'test_1');
      
      final json = record.toJson();
      final decoded = StepRecord.fromJson(json);

      expect(decoded.count, record.count);
      expect(decoded.id, record.id);
      expect(decoded.timestamp.millisecondsSinceEpoch, 
             record.timestamp.millisecondsSinceEpoch);
    });
  });

  group('HRRecord', () {
    test('creates record correctly', () {
      final now = DateTime.now();
      final record = HRRecord(
        timestamp: now,
        bpm: 75,
        id: 'test_1',
      );

      expect(record.timestamp, now);
      expect(record.bpm, 75);
      expect(record.id, 'test_1');
    });

    test('equality works correctly', () {
      final now = DateTime.now();
      final record1 = HRRecord(timestamp: now, bpm: 75, id: 'test_1');
      final record2 = HRRecord(timestamp: now, bpm: 75, id: 'test_1');
      final record3 = HRRecord(timestamp: now, bpm: 75, id: 'test_2');

      expect(record1, equals(record2));
      expect(record1, isNot(equals(record3)));
    });

    test('toJson and fromJson work correctly', () {
      final now = DateTime.now();
      final record = HRRecord(timestamp: now, bpm: 75, id: 'test_1');
      
      final json = record.toJson();
      final decoded = HRRecord.fromJson(json);

      expect(decoded.bpm, record.bpm);
      expect(decoded.id, record.id);
      expect(decoded.timestamp.millisecondsSinceEpoch, 
             record.timestamp.millisecondsSinceEpoch);
    });
  });

  group('Data deduplication', () {
    test('removes duplicate records by ID', () {
      final now = DateTime.now();
      final records = [
        StepRecord(timestamp: now, count: 100, id: 'test_1'),
        StepRecord(timestamp: now, count: 150, id: 'test_1'),
        StepRecord(timestamp: now, count: 200, id: 'test_2'),
      ];

      final unique = records.toSet().toList();
      
      expect(unique.length, 2);
      expect(unique.map((r) => r.id).toSet(), {'test_1', 'test_2'});
    });
  });
}