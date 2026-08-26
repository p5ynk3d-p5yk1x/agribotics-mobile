import 'dart:io';

import 'package:agribotics/features/disease/data/disease_repository.dart';
import 'package:agribotics/features/disease/data/disease_state.dart';
import 'package:flutter_riverpod/legacy.dart';


class DiseaseNotifier extends StateNotifier<DiseaseState> {

  final DiseaseRepository repository;

  DiseaseNotifier(this.repository,) : super(
    const DiseaseState(),
  );

  Future<void> submitDiagnosis(File image,) async {
    state = state.copyWith(
      loading: true,
      success: false,
      error: null,
    );

    try {
      await repository.createJob(image);
      state = state.copyWith(
        loading: false,
        success: true,
      );

    } catch (e) {

      state = state.copyWith(
        loading: false,
        success: false,
        error: e.toString(),
      );

    }
  }
  void reset() {
    state = const DiseaseState();
  }
}