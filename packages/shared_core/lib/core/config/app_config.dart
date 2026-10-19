enum Environment { dev, staging, prod }

class AppConfig {
  final Environment environment;
  final String appTitle;
  final String apiBaseUrl;
  final bool enableDebugLogs;
  final bool useMockFallback;

  static AppConfig? _instance;
  static AppConfig get instance => _instance ??= AppConfig.prod();

  const AppConfig({
    required this.environment,
    required this.appTitle,
    required this.apiBaseUrl,
    this.enableDebugLogs = true,
    this.useMockFallback = true,
  });

  factory AppConfig.dev() => const AppConfig(
    environment: Environment.dev,
    appTitle: 'FoodGo Dev',
    apiBaseUrl: 'https://dev-api.foodgo.app',
    enableDebugLogs: true,
    useMockFallback: true,
  );

  factory AppConfig.staging() => const AppConfig(
    environment: Environment.staging,
    appTitle: 'FoodGo Staging',
    apiBaseUrl: 'https://staging-api.foodgo.app',
    enableDebugLogs: true,
    useMockFallback: false,
  );

  factory AppConfig.prod() => const AppConfig(
    environment: Environment.prod,
    appTitle: 'FoodGo',
    apiBaseUrl: 'https://api.foodgo.app',
    enableDebugLogs: false,
    useMockFallback: false,
  );

  static void initialize(AppConfig config) {
    _instance = config;
  }
}
