import 'package:dio/dio.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'models/create_soil_job_request.dart';
import 'soil_repository.dart';
import 'soil_state.dart';

class SoilNotifier extends StateNotifier<SoilState> {
  final SoilRepository repository;

  SoilNotifier(this.repository): super(const SoilState());

  Future<bool> submitAnalysis(CreateSoilJobRequest request) async {
    state = const SoilState(loading: true);

    try {
      final response = await repository.createSoilJob(request);

      state = SoilState(
        loading: false,
        success: true,
        jobId: response['jobId']?.toString(),
        status: response['status']?.toString(),
      );

      return true;
    } on DioException catch (error) {
      state = SoilState(
        loading: false,
        error: _extractError(error),
      );

      return false;
    } catch (error) {
      state = SoilState(
        loading: false,
        error: error.toString(),
      );

      return false;
    }
  }

  void reset() {
    state = const SoilState();
  }

  String _extractError(DioException error) {
    final data = error.response?.data;

    if (data is Map) {
      final message = data['message'];

      if (message is List) return message.join(', ');
      if (message != null) return message.toString();
    }

    return error.message ?? 'Unable to create soil analysis job.';
  }
}