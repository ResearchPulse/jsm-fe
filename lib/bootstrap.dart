import 'dart:async';
import 'dart:developer';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app/app_bloc_observer.dart';
import 'core/constants/api_endpoints.dart';
import 'core/runtime/desktop_runtime_config.dart';

Future<void> bootstrap(
  FutureOr<Widget> Function() builder, {
  List<String> runtimeArgs = const <String>[],
}) async {
  FlutterError.onError = (details) {
    log(details.exceptionAsString(), stackTrace: details.stack);
  };

  Bloc.observer = const AppBlocObserver();

  WidgetsFlutterBinding.ensureInitialized();

  try {
    final runtimeConfig = DesktopRuntimeConfig.fromArgs(runtimeArgs);
    if (runtimeConfig != null) {
      ApiEndpoints.configureRuntime(runtimeConfig);
    }
  } catch (error, stack) {
    log(
      'Invalid native desktop runtime configuration: $error',
      stackTrace: stack,
    );
    rethrow;
  }

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    log('Could not load .env file, fallback to defaults/dart-define: $e');
  }

  runApp(await builder());
}
