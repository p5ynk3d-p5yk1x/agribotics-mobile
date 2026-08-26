sealed class WeedState {
  const WeedState();
}

class WeedInitial extends WeedState {
  const WeedInitial();
}

class WeedUploading extends WeedState {
  const WeedUploading();
}

class WeedQueued extends WeedState {
  final String jobId;
  const WeedQueued(this.jobId);
}

class WeedCompleted extends WeedState {
  final Map<String,dynamic> result;

  const WeedCompleted(this.result);
}

class WeedError extends WeedState {
  final String message;

  const WeedError(this.message);
}