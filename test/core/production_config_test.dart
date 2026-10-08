import 'package:eschool_app/app/router/routes.dart';
import 'package:eschool_app/core/config/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Production API configuration', () {
    test('canonical production URL is pinned', () {
      expect(
        AppConfig.prodApiBaseUrl,
        'https://eschool.whitelabel.co.id/api/v1',
      );
    });
    test('no legacy hosts in canonical URLs', () {
      for (final String u in <String>[
        AppConfig.prodApiBaseUrl,
        AppConfig.websiteUrl,
        AppConfig.apiDocsUrl,
      ]) {
        expect(u, isNot(contains('sikadpro.app')));
        expect(u, isNot(contains('sikadpro.whitelabel')));
      }
    });
    test('website + docs URLs', () {
      expect(AppConfig.websiteUrl, 'https://eschool.whitelabel.co.id');
      expect(AppConfig.apiDocsUrl, 'https://eschool.whitelabel.co.id/api-docs');
    });
    test('dev defaults remain environment-aware', () {
      expect(
        AppConfig.devApiBaseUrlEmulator,
        'http://10.0.2.2:8000/api/v1',
      );
      expect(AppConfig.devApiBaseUrlIos, 'http://127.0.0.1:8000/api/v1');
    });
    test('about route registered', () {
      expect(Routes.about, '/about');
    });
  });
}
