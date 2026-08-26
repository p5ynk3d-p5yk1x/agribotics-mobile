sealed class WeedJobsState {
  const WeedJobsState();
}

class WeedJobsLoading extends WeedJobsState {}

class WeedJobsLoaded extends WeedJobsState {
  final List<Map<String, dynamic>> jobs;

  const WeedJobsLoaded(this.jobs);
}

class WeedJobsError extends WeedJobsState {
  final String message;

  const WeedJobsError(this.message);
}