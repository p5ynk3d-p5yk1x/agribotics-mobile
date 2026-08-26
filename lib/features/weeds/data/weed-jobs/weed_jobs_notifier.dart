
import 'package:agribotics/features/weeds/data/weed-jobs/weed_jobs_state.dart';
import 'package:agribotics/features/weeds/data/weed_repository.dart';
import 'package:flutter_riverpod/legacy.dart';

class WeedJobsNotifier extends StateNotifier<WeedJobsState> {

  final WeedRepository repository;

  WeedJobsNotifier(this.repository) : super(WeedJobsLoading());

  Future<void> loadJobs() async {
    try {
      state = WeedJobsLoading();

      final jobs = await repository.getAllWeedJobs();
      state = WeedJobsLoaded(jobs);
    } catch (e) {
      state = WeedJobsError(
        e.toString(),
      );
    }
  }
}