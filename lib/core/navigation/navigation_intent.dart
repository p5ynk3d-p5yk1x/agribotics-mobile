/// A user-facing destination and the language that can identify it offline.
class NavigationIntent {
  const NavigationIntent({
    required this.id,
    required this.label,
    required this.route,
    required this.purpose,
    this.keywords = const [],
    this.phrases = const [],
    this.sentences = const [],
    this.negativeKeywords = const [],
    this.contextPaths = const [],
  });

  final String id;
  final String label;
  final String route;
  final String purpose;
  final List<String> keywords;
  final List<String> phrases;
  final List<String> sentences;
  final List<String> negativeKeywords;
  final List<String> contextPaths;
}
