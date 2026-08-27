import 'dart:async';

import 'package:flutter/material.dart';

class RefreshCountdown extends StatefulWidget {
  const RefreshCountdown({super.key, required this.nextRefreshAt});
  final DateTime? nextRefreshAt;

  @override
  State<RefreshCountdown> createState() => _RefreshCountdownState();
}

class _RefreshCountdownState extends State<RefreshCountdown> {
  Timer? _timer;
  @override
  void initState() { super.initState(); _timer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() {})); }
  @override
  void dispose() { _timer?.cancel(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    final target = widget.nextRefreshAt;
    if (target == null) return const Text('Refresh timing unavailable');
    final remaining = target.difference(DateTime.now().toUtc());
    if (remaining.isNegative) return const Text('Refresh available now');
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
    return Text('Refresh available in ${minutes}m ${seconds}s');
  }
}
