class SoilState {
  final bool loading;
  final bool success;
  final String? error;
  final String? jobId;
  final String? status;

  const SoilState({
    this.loading = false,
    this.success = false,
    this.error,
    this.jobId,
    this.status,
  });

  SoilState copyWith({
    bool? loading,
    bool? success,
    String? error,
    String? jobId,
    String? status,
    bool clearError = false,
  }) {
    return SoilState(
      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: clearError ? null : error ?? this.error,
      jobId: jobId ?? this.jobId,
      status: status ?? this.status,
    );
  }
}