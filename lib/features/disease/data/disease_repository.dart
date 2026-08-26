import 'dart:io';

import 'package:dio/dio.dart';

class DiseaseRepository {
  final Dio dio;

  DiseaseRepository(this.dio);

  Future<String> createJob(File file) async {
    try {
      final formData = FormData.fromMap({
        'jobType': 'DISEASE',
        'file': await MultipartFile.fromFile(
          file.path,
          filename: file.path.split('/').last,
        ),
      });

      final response = await dio.post(
        '/api/jobs',
        data: formData,
      );
      print(response);
      return response.data['jobId'];
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Request path: ${e.requestOptions.path}');
      rethrow;
    } catch (e, stackTrace) {
      print('Unexpected error: $e');
      print(stackTrace);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getJob(String jobId) async {
    final response = await dio.get("/jobs/$jobId");
    return Map<String, dynamic>.from(response.data);
  }

  Future<List<Map<String, dynamic>>> getAllDiseaseJobs() async {
    final response = await dio.get("/jobs/type/DISEASE",);
    return (response.data as List)
        .map((e) => Map<String, dynamic>.from(e))
        .toList();
  }
}