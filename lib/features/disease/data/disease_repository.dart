import 'dart:io';
import 'package:dio/dio.dart';

class DiseaseRepository {
  final Dio dio;

  DiseaseRepository(this.dio);

  Future<String> createJob(File file) async {
    try {
      final formData = FormData.fromMap({
        'jobType': 'DISEASE',
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
      });
      final response = await dio.post('/api/jobs', data: formData);
      return response.data['jobId'].toString();
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
    final response = await dio.get('/api/jobs/$jobId');
    return Map<String, dynamic>.from(response.data as Map);
  }

  Future<List<Map<String, dynamic>>> getAllDiseaseJobs() async {
    final response = await dio.get('/api/jobs/type/DISEASE');
    final data = response.data;
    if (data is! List) return [];
    return data.map((job) => Map<String, dynamic>.from(job as Map)).toList();
  }
}