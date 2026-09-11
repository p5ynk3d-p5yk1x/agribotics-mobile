import 'package:agribotics/core/navigation/navigation_intents.dart';
import 'package:agribotics/core/navigation/navigation_matcher.dart';
import 'package:agribotics/core/navigation/navigation_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const matcher = NavigationMatcher(intents: navigationIntents);

  void expectsRoute(String request, String route) {
    final result = matcher.match(request);
    expect(result.confidence, NavigationConfidence.confident, reason: request);
    expect(result.best?.intent.route, route, reason: request);
  }

  group('soil navigation', () {
    test('matches detection requests', () {
      expectsRoute('check my soil', '/soil/detection');
      expectsRoute('test soil nutrients', '/soil/detection');
      expectsRoute('Analyze the nutrients in my soil!', '/soil/detection');
    });

    test('specific history language beats general soil language', () {
      expectsRoute('show my soil history', '/soil/history');
      expectsRoute('show previous soil reports', '/soil/history');
      expectsRoute('show my previous soil tests', '/soil/history');
    });
  });

  group('crop navigation', () {
    test('matches weed destinations', () {
      expectsRoute('detect weeds', '/weed/detection');
      expectsRoute('scan my field for weeds', '/weed/detection');
      expectsRoute('show previous weed scans', '/weed/history');
    });

    test('matches disease destinations', () {
      expectsRoute('check my plant for disease', '/disease/detection');
      expectsRoute('show disease history', '/disease/history');
    });
  });

  test('matches marketplace and settings', () {
    expectsRoute('open market', '/market');
    expectsRoute('show products', '/market');
    expectsRoute('open settings', '/settings');
  });

  test('does not navigate for irrelevant or generic farm input', () {
    expect(matcher.match('hello').confidence, NavigationConfidence.noMatch);
    expect(matcher.match('tell me about my farm').confidence, NavigationConfidence.noMatch);
  });

  test('reports tied, conflicting evidence as ambiguous', () {
    final result = matcher.match('soil analysis and weed detection');
    expect(result.confidence, NavigationConfidence.ambiguous);
    expect(result.matches.take(2).map((match) => match.score), everyElement(4));
  });

  test('uses route context only for deterministic follow-ups', () {
    final result = matcher.match('show the latest one', currentRoute: '/soil/history');
    expect(result.best?.intent.route, '/soil/history');
    expect(result.confidence, NavigationConfidence.noMatch,
        reason: 'A context hint alone must not cause automatic navigation.');
  });
}
