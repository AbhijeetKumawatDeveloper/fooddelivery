import 'package:flutter_bloc/flutter_bloc.dart';

import 'app_logger.dart';

class AppBlocObserver extends BlocObserver {
  final AppLogger logger;

  AppBlocObserver({this.logger = const ConsoleAppLogger()});

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    logger.debug('Created: ${bloc.runtimeType}', tag: 'BlocObserver');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    logger.debug(
      '${bloc.runtimeType} -> State: ${change.nextState.runtimeType}',
      tag: 'BlocObserver',
    );
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    logger.error(
      '${bloc.runtimeType} encountered error: $error',
      tag: 'BlocObserver',
      error: error,
      stackTrace: stackTrace,
    );
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    logger.debug('Closed: ${bloc.runtimeType}', tag: 'BlocObserver');
  }
}
