import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:integration_test/integration_test.dart';
import 'package:obee_mobile/src/core/storage/token_storage.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'native secure storage persists and isolates environment sessions',
    (tester) async {
      const native = FlutterSecureStorage();
      const dev = SecureTokenStorage(native, namespace: 'integration_dev');
      const staging = SecureTokenStorage(
        native,
        namespace: 'integration_staging',
      );
      await dev.clearToken();
      await staging.clearToken();
      try {
        await dev.writeToken('dev-session');
        await staging.writeToken('staging-session');
        const reopened = SecureTokenStorage(
          FlutterSecureStorage(),
          namespace: 'integration_dev',
        );
        expect(await reopened.readToken(), 'dev-session');
        await dev.clearToken();
        expect(await reopened.readToken(), null);
        expect(await staging.readToken(), 'staging-session');
      } finally {
        await dev.clearToken();
        await staging.clearToken();
      }
    },
  );
}
