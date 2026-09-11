import 'navigation_intent.dart';

enum NavigationConfidence { noMatch, ambiguous, confident }

class NavigationMatch {
  const NavigationMatch(this.intent, this.score);

  final NavigationIntent intent;
  final int score;
}

class NavigationResult {
  const NavigationResult({
    required this.confidence,
    required this.matches,
  });

  final NavigationConfidence confidence;
  final List<NavigationMatch> matches;

  NavigationMatch? get best => matches.isEmpty ? null : matches.first;
  List<NavigationMatch> get alternatives => matches.skip(1).take(2).toList();
}
