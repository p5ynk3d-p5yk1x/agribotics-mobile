import 'package:agribotics/core/auth/auth-repository.dart';
import 'package:agribotics/core/auth/auth_notifier.dart';
import 'package:agribotics/core/auth/auth_state.dart';
import 'package:agribotics/features/disease/data/disease_notifier.dart';
import 'package:agribotics/features/disease/data/disease_repository.dart';
import 'package:agribotics/features/disease/data/disease_state.dart';
import 'package:agribotics/features/weeds/data/weed_notifier.dart';
import 'package:agribotics/features/weeds/data/weed_repository.dart';
import 'package:agribotics/features/weeds/data/weed_state.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final dioProvider = Provider<Dio>((ref) {

  final dio = Dio(
    BaseOptions(
      baseUrl: "http://192.168.1.31:3000",
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  final storage = FlutterSecureStorage();

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await storage.read(
          key: "accessToken",
        );
        if(token != null){
          options.headers["Authorization"] =
          "Bearer $token";
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthRepository(dio);
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
  );
});

final weedRepositoryProvider = Provider<WeedRepository>(
      (ref) => WeedRepository(ref.watch(dioProvider)),
);

final weedProvider = StateNotifierProvider<WeedNotifier, WeedState>(
      (ref) => WeedNotifier(ref.watch(weedRepositoryProvider)),
);

final weedJobsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  return ref
      .read(weedRepositoryProvider)
      .getAllWeedJobs();
});

final diseaseRepositoryProvider = Provider<DiseaseRepository>(
      (ref) => DiseaseRepository(ref.watch(dioProvider),),
);

final diseaseProvider = StateNotifierProvider<DiseaseNotifier, DiseaseState>(
      (ref) => DiseaseNotifier(ref.watch(diseaseRepositoryProvider)),
);