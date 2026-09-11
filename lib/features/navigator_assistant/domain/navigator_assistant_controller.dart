import 'package:flutter/foundation.dart';

import '../../../core/navigation/navigation_intent.dart';
import '../../../core/navigation/navigation_intents.dart';
import '../../../core/navigation/navigation_matcher.dart';
import '../../../core/navigation/navigation_result.dart';

enum AssistantRole { user, assistant }

class AssistantMessage {
  const AssistantMessage({required this.role, required this.text, required this.timestamp});

  final AssistantRole role;
  final String text;
  final DateTime timestamp;
}

class NavigatorAssistantController extends ChangeNotifier {
  NavigatorAssistantController({NavigationMatcher? matcher})
      : matcher = matcher ?? const NavigationMatcher(intents: navigationIntents),
        messages = [
          AssistantMessage(
            role: AssistantRole.assistant,
            text: 'Where would you like to go?',
            timestamp: DateTime.now(),
          ),
        ];

  final NavigationMatcher matcher;
  final List<AssistantMessage> messages;
  bool isExpanded = false;
  bool isProcessing = false;
  String currentRoute = '/dashboard';
  String? previousRoute;
  String? lastUserRequest;
  NavigationIntent? lastIntent;
  NavigationResult? pendingResult;

  void updateRoute(String route) {
    if (route == currentRoute) return;
    previousRoute = currentRoute;
    currentRoute = route;
  }

  void toggle() {
    isExpanded = !isExpanded;
    notifyListeners();
  }

  void collapse() {
    if (!isExpanded) return;
    isExpanded = false;
    notifyListeners();
  }

  void beginRequest(String input) {
    lastUserRequest = input;
    isProcessing = true;
    pendingResult = null;
    messages.add(AssistantMessage(role: AssistantRole.user, text: input, timestamp: DateTime.now()));
    notifyListeners();
  }

  NavigationResult completeRequest(String input) {
    final result = matcher.match(input, currentRoute: currentRoute, lastIntent: lastIntent);
    isProcessing = false;
    pendingResult = result;
    final best = result.best;
    if (result.confidence == NavigationConfidence.confident && best != null) {
      lastIntent = best.intent;
      messages.add(AssistantMessage(
        role: AssistantRole.assistant,
        text: best.intent.route == currentRoute
            ? 'You are already on ${best.intent.label}.'
            : 'Taking you to ${best.intent.label}.',
        timestamp: DateTime.now(),
      ));
    } else if (result.confidence == NavigationConfidence.ambiguous) {
      messages.add(AssistantMessage(
        role: AssistantRole.assistant,
        text: 'I found a few possible destinations. Which one did you mean?',
        timestamp: DateTime.now(),
      ));
    } else {
      messages.add(AssistantMessage(
        role: AssistantRole.assistant,
        text: "I'm not sure where you want to go. Try asking:\n• Check my soil\n• Detect weeds\n• Show disease history\n• Open the market",
        timestamp: DateTime.now(),
      ));
    }
    notifyListeners();
    return result;
  }

  void choose(NavigationIntent intent) {
    lastIntent = intent;
    pendingResult = null;
    messages.add(AssistantMessage(
      role: AssistantRole.assistant,
      text: 'Taking you to ${intent.label}.',
      timestamp: DateTime.now(),
    ));
    notifyListeners();
  }
}
