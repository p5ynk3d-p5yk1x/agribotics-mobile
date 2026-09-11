import 'models/create_soil_job_request.dart';
import 'soil_api.dart';

class SoilRepository {
  final SoilApi api;

  SoilRepository(this.api);

  Future<Map<String,dynamic>> createSoilJob(CreateSoilJobRequest request) {
    return api.createSoilJob(request);
  }

  Future<Map<String,dynamic>> getJob(String jobId) {
    return api.getJob(jobId);
  }

  Future<List<Map<String,dynamic>>> getAllSoilJobs() {
    return api.getAllSoilJobs();
  }
}