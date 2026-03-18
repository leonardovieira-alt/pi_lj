import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    const fromDefine = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (fromDefine.isNotEmpty) {
      return fromDefine;
    }

    if (kIsWeb) {
      return 'https://apiserverlj.up.railway.app/api';
    }

    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'https://apiserverlj.up.railway.app/api';
    }

    return 'https://apiserverlj.up.railway.app/api';
  }
}
