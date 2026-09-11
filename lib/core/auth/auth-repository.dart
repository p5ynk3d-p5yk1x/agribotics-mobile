import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  static const sessionDuration = Duration(hours: 20);
  static const _accessTokenKey = 'accessToken';
  static const _signedInAtKey = 'signedInAt';

  final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  bool initialized = false;

  AuthRepository(this.dio);

  Future<void> initialize() async {
    if (initialized) return;
    await googleSignIn.initialize(
      serverClientId: '1022984136899-u8j184fjc400pouprgqf56fa6qh9lqea.apps.googleusercontent.com',
    );
    initialized = true;
  }

  Future<void> signInWithGoogle() async {
    await initialize();

    // Opens Google account picker
    final GoogleSignInAccount user = await GoogleSignIn.instance.authenticate();
    // Get the ID token
    final String? idToken = user.authentication.idToken;

    if (idToken == null) {
      throw Exception('Google did not return an ID token');
    }
    // Send it to your NestJS backend
    await sendTokenToBackend(idToken);
  }

  Future<void> sendTokenToBackend(String idToken) async {
    final response = await dio.post(
      '/api/auth/google/mobile',
      data: {
        'idToken': idToken,
      },
    );
    final jwt = response.data['accessToken'] as String;
    await secureStorage.write(
      key: _accessTokenKey,
      value: jwt,
    );
    await secureStorage.write(
      key: _signedInAtKey,
      value: DateTime.now().toUtc().millisecondsSinceEpoch.toString(),
    );
  }

  Future<String?> getAccessToken() {
    return secureStorage.read(key: _accessTokenKey);
  }

  Future<void> signOut() async {
    try {
      await googleSignIn.signOut();
    } finally {
      await clearSession();
    }
  }

  Future<void> clearSession() async {
    await secureStorage.delete(key: _accessTokenKey);
    await secureStorage.delete(key: _signedInAtKey);
  }

  Future<Duration?> validSessionRemaining() async {
    final token = await getAccessToken();
    final signedInAtValue = await secureStorage.read(key: _signedInAtKey);
    final signedInAtMilliseconds = int.tryParse(signedInAtValue ?? '');

    if (token == null || token.isEmpty || signedInAtMilliseconds == null) {
      await clearSession();
      return null;
    }

    final signedInAt = DateTime.fromMillisecondsSinceEpoch(
      signedInAtMilliseconds,
      isUtc: true,
    );
    final remaining =
        sessionDuration - DateTime.now().toUtc().difference(signedInAt);
    if (remaining <= Duration.zero || remaining > sessionDuration) {
      await clearSession();
      return null;
    }

    return remaining;
  }
}
