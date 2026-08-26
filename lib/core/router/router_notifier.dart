import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_providers.dart';
import '../auth/auth_state.dart';

class RouterNotifier extends ChangeNotifier {
  late final ProviderSubscription<AuthState>_subscription;
  RouterNotifier(Ref ref) {
    _subscription = ref.listen<AuthState>(
      authProvider,
          (_, __) => notifyListeners(),
    );
  }

  @override
  void dispose() {
    _subscription.close();
    super.dispose();
  }
}

final routerNotifierProvider = Provider<RouterNotifier>(
      (ref) => RouterNotifier(ref),
);