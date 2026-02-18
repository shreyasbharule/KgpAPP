enum AppEnvironment { dev, stage, prod }

class AppConfig {
  static const String _environmentRaw = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get environment {
    switch (_environmentRaw.toLowerCase()) {
      case 'prod':
      case 'production':
        return AppEnvironment.prod;
      case 'stage':
      case 'staging':
        return AppEnvironment.stage;
      case 'dev':
      default:
        return AppEnvironment.dev;
    }
  }

  static String get envName => environment.name;

  static String get apiBaseUrl {
    const customBase = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (customBase.isNotEmpty) return customBase;

    switch (environment) {
      case AppEnvironment.dev:
        return 'http://10.0.2.2:8000';
      case AppEnvironment.stage:
        return 'https://stage-api.university.edu';
      case AppEnvironment.prod:
        return 'https://api.university.edu';
    }
  }
}
