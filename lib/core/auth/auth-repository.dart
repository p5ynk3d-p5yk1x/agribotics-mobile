
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthRepository {
  final Dio dio;
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();
  final GoogleSignIn googleSignIn = GoogleSignIn.instance;
  bool initialized = false;

  AuthRepository(this.dio);


  Future<void> initialize() async {
    if(initialized) return;
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
      '/auth/google/mobile',
      data: {
        'idToken': idToken,
      },
    );
    final jwt = response.data['accessToken'] as String;
    print("jwt: $jwt");
    await secureStorage.write(
      key: 'accessToken',
      value: jwt,
    );
  }

  Future<String?> getAccessToken() {
    return secureStorage.read(key: 'accessToken');
  }

  Future<void> signOut() async {
    await googleSignIn.signOut();
    await secureStorage.delete(key: 'accessToken');
  }

  Future<bool> isLoggedIn() async {
    final token = await getAccessToken();
    return token != null;
  }
}