import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/errors/failures.dart';
import 'package:fooddelivery/core/errors/result.dart';

void main() {
  group('Result Monad & Failure Tests', () {
    test('Result.success returns expected values and flags', () {
      const result = Result<int>.success(42);

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.dataOrNull, 42);
      expect(result.failureOrNull, isNull);

      final mapped = result.map((data) => 'Value: $data');
      expect(mapped.dataOrNull, 'Value: 42');

      final value = result.when(
        success: (data) => data * 2,
        failure: (f) => -1,
      );
      expect(value, 84);
    });

    test('Result.failure returns expected failure details', () {
      const failure = ServerFailure('Internal error', '500');
      const result = Result<int>.failure(failure);

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.dataOrNull, isNull);
      expect(result.failureOrNull, failure);

      final mapped = result.map((data) => 'Value: $data');
      expect(mapped.isFailure, isTrue);
      expect(mapped.failureOrNull, failure);

      final errorMsg = result.when(
        success: (data) => 'Success',
        failure: (f) => f.message,
      );
      expect(errorMsg, 'Internal error');
    });

    test('Failure hierarchy props and toString comparison', () {
      const f1 = ServerFailure('Error', '500');
      const f2 = ServerFailure('Error', '500');
      const f3 = CacheFailure('Cache error');
      const f4 = AuthFailure('Auth error');
      const f5 = NetworkFailure('Network error');
      const f6 = NotFoundFailure('Not found');
      const f7 = ValidationFailure('Validation error');

      expect(f1, equals(f2));
      expect(f1.toString(), contains('ServerFailure [500]: Error'));
      expect(f3.toString(), contains('CacheFailure: Cache error'));
      expect(f4, isA<Failure>());
      expect(f5, isA<Failure>());
      expect(f6, isA<Failure>());
      expect(f7, isA<Failure>());
    });
  });
}
