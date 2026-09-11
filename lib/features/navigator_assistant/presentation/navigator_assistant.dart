import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../../core/navigation/navigation_result.dart';
import '../../../core/theme/app_theme.dart';
import '../domain/navigator_assistant_controller.dart';

class NavigatorAssistant extends StatefulWidget {
  const NavigatorAssistant({super.key, required this.controller});

  final NavigatorAssistantController controller;

  @override
  State<NavigatorAssistant> createState() => _NavigatorAssistantState();
}

class _NavigatorAssistantState extends State<NavigatorAssistant> {
  static const _buttonSize = 54.0;
  final _inputController = TextEditingController();
  final _scrollController = ScrollController();
  Offset? _position;

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final input = _inputController.text.trim();
    if (input.isEmpty || widget.controller.isProcessing) return;
    _inputController.clear();
    widget.controller.beginRequest(input);
    _scrollToEnd();
    // One frame makes the local processing state perceptible without adding a
    // network-like delay.
    await Future<void>.delayed(const Duration(milliseconds: 80));
    if (!mounted) return;
    final result = widget.controller.completeRequest(input);
    _scrollToEnd();
    if (result.confidence == NavigationConfidence.confident && result.best != null) {
      final route = result.best!.intent.route;
      if (route != widget.controller.currentRoute && mounted) context.go(route);
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) => LayoutBuilder(
        builder: (context, constraints) {
          final maxX = (constraints.maxWidth - _buttonSize)
              .clamp(0.0, double.infinity)
              .toDouble();
          final maxY = (constraints.maxHeight - _buttonSize - 12)
              .clamp(0.0, double.infinity)
              .toDouble();
          final fallback = Offset(
            maxX,
            maxY <= 12 ? maxY : (maxY - 80).clamp(12.0, maxY).toDouble(),
          );
          final position = _clamp(_position ?? fallback, maxX, maxY);
          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (!widget.controller.isExpanded)
                AnimatedPositioned(
                  key: const ValueKey('navigator-assistant-button-position'),
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  left: position.dx,
                  top: position.dy,
                  child: GestureDetector(
                    onPanUpdate: (details) => setState(() {
                      _position = _clamp(position + details.delta, maxX, maxY);
                    }),
                    onPanEnd: (_) => setState(() {
                      final current = _clamp(_position ?? position, maxX, maxY);
                      _position = Offset(current.dx < maxX / 2 ? 0 : maxX, current.dy);
                    }),
                    child: Semantics(
                      button: true,
                      label: 'Open Navigator Assistant',
                      child: Material(
                        key: const ValueKey('navigator-assistant-button'),
                        elevation: 8,
                        color: AppTheme.primary.withOpacity(0.92),
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: widget.controller.toggle,
                          child: const SizedBox(
                            width: _buttonSize,
                            height: _buttonSize,
                            child: Icon(LucideIcons.navigation, color: Colors.white, size: 23),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              AnimatedPositioned(
                key: const ValueKey('navigator-assistant-drawer-position'),
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                left: 0,
                right: 0,
                height: (constraints.maxHeight * 0.62)
                    .clamp(300.0, 560.0)
                    .toDouble(),
                bottom: widget.controller.isExpanded ? 0 : -600,
                child: _AssistantDrawer(
                  controller: widget.controller,
                  inputController: _inputController,
                  scrollController: _scrollController,
                  onSubmit: _submit,
                  onChoice: (match) {
                    widget.controller.choose(match.intent);
                    if (match.intent.route != widget.controller.currentRoute) context.go(match.intent.route);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Offset _clamp(Offset value, double maxX, double maxY) => Offset(
        value.dx.clamp(0.0, maxX).toDouble(),
        value.dy.clamp(0.0, maxY).toDouble(),
      );
}

class _AssistantDrawer extends StatelessWidget {
  const _AssistantDrawer({
    required this.controller,
    required this.inputController,
    required this.scrollController,
    required this.onSubmit,
    required this.onChoice,
  });

  final NavigatorAssistantController controller;
  final TextEditingController inputController;
  final ScrollController scrollController;
  final VoidCallback onSubmit;
  final ValueChanged<NavigationMatch> onChoice;

  @override
  Widget build(BuildContext context) {
    final choices = controller.pendingResult?.confidence == NavigationConfidence.ambiguous
        ? controller.pendingResult!.matches.take(3).toList()
        : const <NavigationMatch>[];
    return Material(
      key: const ValueKey('navigator-assistant-drawer'),
      elevation: 24,
      color: AppTheme.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 10, 8),
              child: Row(
                children: [
                  const Icon(LucideIcons.navigation, color: AppTheme.primary, size: 20),
                  const SizedBox(width: 10),
                  Text('Navigator Assistant', style: Theme.of(context).textTheme.titleLarge),
                  const Spacer(),
                  IconButton(
                    key: const ValueKey('navigator-assistant-collapse'),
                    tooltip: 'Collapse assistant',
                    onPressed: controller.collapse,
                    icon: const Icon(LucideIcons.chevronDown),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(18),
                itemCount: controller.messages.length + (controller.isProcessing ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == controller.messages.length) return const _ProcessingBubble();
                  return _MessageBubble(message: controller.messages[index]);
                },
              ),
            ),
            if (choices.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: choices
                      .map((choice) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ActionChip(label: Text(choice.intent.label), onPressed: () => onChoice(choice)),
                          ))
                      .toList(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
              child: TextField(
                key: const ValueKey('navigator-assistant-input'),
                controller: inputController,
                enabled: !controller.isProcessing,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: 'Ask where you want to go…',
                  filled: true,
                  fillColor: AppTheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(22), borderSide: BorderSide.none),
                  suffixIcon: IconButton(
                    key: const ValueKey('navigator-assistant-send'),
                    tooltip: 'Find destination',
                    onPressed: controller.isProcessing ? null : onSubmit,
                    icon: const Icon(LucideIcons.send, color: AppTheme.primary),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});
  final AssistantMessage message;

  @override
  Widget build(BuildContext context) {
    final isUser = message.role == AssistantRole.user;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 310),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 11),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.primary : AppTheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(message.text, style: TextStyle(color: isUser ? Colors.white : AppTheme.onSurface)),
      ),
    );
  }
}

class _ProcessingBubble extends StatelessWidget {
  const _ProcessingBubble();

  @override
  Widget build(BuildContext context) => const Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
              SizedBox(width: 10),
              Text('Analyzing locally…'),
            ],
          ),
        ),
      );
}
