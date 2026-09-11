import 'package:dio/dio.dart';
import 'models/create_soil_job_request.dart';

class SoilApi {
  final Dio dio;

  SoilApi(this.dio);

  Future<Map<String,dynamic>> createSoilJob(CreateSoilJobRequest request) async {
    final response = await dio.post('/api/jobs/soil',data: request.toJson());
    return Map<String,dynamic>.from(response.data as Map);
  }

  Future<Map<String,dynamic>> getJob(String jobId) async {
    final response = await dio.get('/api/jobs/$jobId');
    return Map<String,dynamic>.from(response.data as Map);
  }

  Future<List<Map<String,dynamic>>> getAllSoilJobs() async {
    final response = await dio.get('/api/jobs/type/SOIL');
    return (response.data as List).map((item) => Map<String,dynamic>.from(item as Map)).toList();
  }
}