import 'package:flutter_test/flutter_test.dart';
import 'package:fva_songs/core/router/admin_redirect.dart';

void main() {
  group('adminRedirect', () {
    test('ne touche pas aux routes publiques', () {
      expect(
        adminRedirect(location: '/', isAdmin: false),
        isNull,
      );
      expect(
        adminRedirect(location: '/song/1', isAdmin: true),
        isNull,
      );
    });

    test('attend la résolution du rôle sur /admin', () {
      expect(adminRedirect(location: '/admin', isAdmin: null), isNull);
    });

    test('envoie un non-admin de /admin vers le login', () {
      expect(
        adminRedirect(location: '/admin', isAdmin: false),
        '/admin/login',
      );
    });

    test('laisse un admin sur /admin', () {
      expect(adminRedirect(location: '/admin', isAdmin: true), isNull);
    });

    test('envoie un admin déjà connecté hors du login', () {
      expect(
        adminRedirect(location: '/admin/login', isAdmin: true),
        '/admin',
      );
    });

    test('laisse un non-admin sur le login', () {
      expect(
        adminRedirect(location: '/admin/login', isAdmin: false),
        isNull,
      );
      expect(
        adminRedirect(location: '/admin/login', isAdmin: null),
        isNull,
      );
    });
  });
}
