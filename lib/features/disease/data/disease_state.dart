class DiseaseState {

  final bool loading;
  final bool success;
  final String? error;

  const DiseaseState({

    this.loading = false,
    this.success = false,
    this.error,

  });

  DiseaseState copyWith({

    bool? loading,
    bool? success,
    String? error,

  }) {
    return DiseaseState(

      loading: loading ?? this.loading,
      success: success ?? this.success,
      error: error,

    );
  }

}