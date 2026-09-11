import 'navigation_intent.dart';
import 'navigation_result.dart';

class NavigationMatcher {
  const NavigationMatcher({
    required this.intents,
    this.keywordWeight = 1,
    this.phraseWeight = 3,
    this.sentenceWeight = 10,
    this.negativeKeywordPenalty = 3,
    this.contextWeight = 2,
    this.minimumScore = 3,
    this.minimumLead = 2,
  });

  final List<NavigationIntent> intents;
  final int keywordWeight;
  final int phraseWeight;
  final int sentenceWeight;
  final int negativeKeywordPenalty;
  final int contextWeight;
  final int minimumScore;
  final int minimumLead;

  NavigationResult match(
    String input, {
    String? currentRoute,
    NavigationIntent? lastIntent,
  }) {
    final normalized = normalize(input);
    if (normalized.isEmpty) {
      return const NavigationResult(confidence: NavigationConfidence.noMatch, matches: []);
    }
    final tokens = normalized.split(' ').toSet();
    final isFollowUp = _followUpTerms.any((term) => _contains(normalized, term));
    final ranked = <NavigationMatch>[];

    for (final intent in intents) {
      var score = 0;
      // Each configured item contributes at most once. Categories may combine,
      // allowing a specific phrase to outrank a shared generic keyword.
      score += intent.keywords.where((word) => tokens.contains(normalize(word))).length * keywordWeight;
      score += intent.phrases.where((phrase) => _contains(normalized, normalize(phrase))).length * phraseWeight;
      score += intent.sentences.where((sentence) => _contains(normalized, normalize(sentence))).length * sentenceWeight;
      score -= intent.negativeKeywords.where((word) => tokens.contains(normalize(word))).length * negativeKeywordPenalty;

      if (isFollowUp &&
          (lastIntent?.id == intent.id || currentRoute == intent.route)) {
        score += contextWeight;
      }
      if (score > 0) ranked.add(NavigationMatch(intent, score));
    }

    ranked.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.intent.id.compareTo(b.intent.id);
    });
    if (ranked.isEmpty || ranked.first.score < minimumScore) {
      return NavigationResult(confidence: NavigationConfidence.noMatch, matches: ranked);
    }
    final lead = ranked.length == 1 ? ranked.first.score : ranked.first.score - ranked[1].score;
    return NavigationResult(
      confidence: lead >= minimumLead ? NavigationConfidence.confident : NavigationConfidence.ambiguous,
      matches: ranked,
    );
  }

  static String normalize(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r"[^a-z0-9\s']"), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static bool _contains(String input, String evidence) =>
      RegExp('(?:^| )${RegExp.escape(evidence)}(?: |\$)').hasMatch(input);

  static const _followUpTerms = ['latest', 'last one', 'that one', 'again', 'previous one'];
}
