import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fooddelivery/core/config/app_config.dart';
import 'package:fooddelivery/core/logger/app_bloc_observer.dart';
import 'package:fooddelivery/core/logger/app_logger.dart';

class TestCubit extends Cubit<int> {
  TestCubit() : super(0);

  void increment() => emit(state + 1);
  void triggerError() => addError(Exception('Test error'), StackTrace.current);
}

class MockLogger implements AppLogger {
  final List<String> logs = [];

  @override
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('DEBUG: $message');
  }

  @override
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('INFO: $message');
  }

  @override
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('WARN: $message');
  }

  @override
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    logs.add('ERROR: $message');
  }
}

void main() {
  group('AppLogger & AppBlocObserver Tests', () {
    test('ConsoleAppLogger logs without throwing', () {
      AppConfig.initialize(AppConfig.dev());
      const logger = ConsoleAppLogger();

      expect(() => logger.debug('Debug log', tag: 'Test'), returnsNormally);
      expect(() => logger.info('Info log', tag: 'Test'), returnsNormally);
      expect(() => logger.warning('Warning log', tag: 'Test'), returnsNormally);
      expect(
        () => logger.error('Error log', tag: 'Test', error: Exception('Oops')),
        returnsNormally,
      );
    });

    test('AppBlocObserver intercepts Cubit events and errors', () {
      final mockLogger = MockLogger();
      final observer = AppBlocObserver(logger: mockLogger);
      Bloc.observer = observer;

      final cubit = TestCubit();
      expect(
        mockLogger.logs.any((l) => l.contains('Created: TestCubit')),
        isTrue,
      );

      cubit.increment();
      expect(mockLogger.logs.any((l) => l.contains('State: int')), isTrue);

      cubit.triggerError();
      expect(
        mockLogger.logs.any((l) => l.contains('encountered error')),
        isTrue,
      );

      cubit.close();
      expect(
        mockLogger.logs.any((l) => l.contains('Closed: TestCubit')),
        isTrue,
      );
    });
  });
}
