import 'package:agribotics/features/navigator_assistant/domain/navigator_assistant_controller.dart';
import 'package:agribotics/features/navigator_assistant/presentation/navigator_assistant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('assistant opens, processes input, and collapses', (tester) async {
    final controller = NavigatorAssistantController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NavigatorAssistant(controller: controller),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('navigator-assistant-button')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('navigator-assistant-button')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('navigator-assistant-drawer')), findsOneWidget);

    await tester.enterText(find.byKey(const ValueKey('navigator-assistant-input')), 'hello');
    await tester.tap(find.byKey(const ValueKey('navigator-assistant-send')));
    await tester.pump(const Duration(milliseconds: 20));
    expect(find.text('Analyzing locally…'), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.textContaining("I'm not sure"), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('navigator-assistant-collapse')));
    await tester.pumpAndSettle();
    expect(controller.isExpanded, isFalse);
    expect(find.byKey(const ValueKey('navigator-assistant-button')), findsOneWidget);
  });

  testWidgets('assistant drag remains within viewport and snaps to an edge', (tester) async {
    final controller = NavigatorAssistantController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: NavigatorAssistant(controller: controller))),
    );
    final button = find.byKey(const ValueKey('navigator-assistant-button'));
    await tester.drag(button, const Offset(-2000, -2000));
    await tester.pumpAndSettle();
    final topLeft = tester.getTopLeft(button);
    expect(topLeft.dx, 0);
    expect(topLeft.dy, greaterThanOrEqualTo(0));

    await tester.drag(button, const Offset(2000, 2000));
    await tester.pumpAndSettle();
    final bottomRight = tester.getBottomRight(button);
    final screen = tester.getSize(find.byType(Scaffold));
    expect(bottomRight.dx, screen.width);
    expect(bottomRight.dy, lessThanOrEqualTo(screen.height));
  });
}
