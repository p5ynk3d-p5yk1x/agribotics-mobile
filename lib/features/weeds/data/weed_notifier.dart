import 'dart:async';
import 'dart:io';
import 'package:flutter_riverpod/legacy.dart';
import '../data/weed_repository.dart';
import 'weed_state.dart';

class WeedNotifier extends StateNotifier<WeedState> {
  final WeedRepository repository;

  WeedNotifier(this.repository) : super(const WeedInitial());

  Future<void> analyze(File image) async {
    try {
      state = const WeedUploading();
      final jobId = await repository.createJob(image);
      state = WeedQueued(jobId);


    } catch (e) {
      state = WeedError(e.toString());
    }
  }
}