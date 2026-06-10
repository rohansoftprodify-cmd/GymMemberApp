import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_member_app/src/core/data/member_repository.dart';
import 'package:gym_member_app/src/core/theme/app_theme_extensions.dart';
import 'package:gym_member_app/src/features/fitness_chat/models/chat_message.dart';

const _suggestedPrompts = [
  'How many calories are in 2 rotis and paneer?',
  'What workout should I do today?',
  'Why am I not losing weight?',
];

class FitnessChatPage extends ConsumerStatefulWidget {
  const FitnessChatPage({super.key});

  @override
  ConsumerState<FitnessChatPage> createState() => _FitnessChatPageState();
}

class _FitnessChatPageState extends ConsumerState<FitnessChatPage> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <FitnessChatMessage>[];
  bool _sending = false;
  int? _quotaRemaining;

  @override
  void initState() {
    super.initState();
    _loadQuota();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadQuota() async {
    try {
      final quota = await ref.read(memberRepositoryProvider).getFitnessChatQuota();
      if (!mounted) return;
      setState(() => _quotaRemaining = (quota['remaining'] as num?)?.toInt());
    } catch (_) {}
  }

  Future<void> _send([String? text]) async {
    final message = (text ?? _controller.text).trim();
    if (message.isEmpty || _sending) return;

    setState(() {
      _sending = true;
      _messages.add(FitnessChatMessage(role: 'user', content: message));
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => !m.isError)
          .map((m) => m.toHistoryEntry())
          .toList();
      history.removeLast();

      final result = await ref.read(memberRepositoryProvider).sendFitnessChatMessage(
            message: message,
            history: history.isEmpty ? null : history,
          );

      final reply = result['reply'] as String? ?? 'No response.';
      final quota = result['quota'];
      if (quota is Map) {
        _quotaRemaining = (quota['remaining'] as num?)?.toInt();
      }

      if (!mounted) return;
      setState(() {
        _messages.add(FitnessChatMessage(role: 'assistant', content: reply));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _messages.add(FitnessChatMessage(
          role: 'assistant',
          content: e.toString().replaceFirst('Exception: ', ''),
          isError: true,
        ));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantics = context.appColors;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('AI Fitness Coach'),
        actions: [
          if (_quotaRemaining != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '$_quotaRemaining left',
                  style: theme.textTheme.labelSmall?.copyWith(color: semantics.mutedText),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              children: [
                _CoachHeader(colorScheme: colorScheme, semantics: semantics),
                const SizedBox(height: 16),
                if (_messages.isEmpty) ...[
                  Text(
                    'Try asking',
                    style: theme.textTheme.labelLarge?.copyWith(color: semantics.mutedText),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _suggestedPrompts.map((prompt) {
                      return ActionChip(
                        label: Text(prompt, style: theme.textTheme.bodySmall),
                        onPressed: _sending ? null : () => _send(prompt),
                      );
                    }).toList(),
                  ),
                ],
                for (final msg in _messages) ...[
                  const SizedBox(height: 10),
                  _ChatBubble(message: msg, semantics: semantics, colorScheme: colorScheme),
                ],
                if (_sending) ...[
                  const SizedBox(height: 10),
                  _TypingIndicator(colorScheme: colorScheme),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _sending ? null : (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Ask about nutrition, workouts, progress…',
                        filled: true,
                        fillColor: semantics.cardBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  IconButton.filled(
                    onPressed: _sending ? null : () => _send(),
                    icon: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoachHeader extends StatelessWidget {
  const _CoachHeader({required this.colorScheme, required this.semantics});

  final ColorScheme colorScheme;
  final AppSemanticColors semantics;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: semantics.cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.psychology_rounded, color: colorScheme.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Available 24/7', style: theme.textTheme.titleSmall),
                const SizedBox(height: 2),
                Text(
                  'Indian meals, workouts, and weight-loss guidance — personalized to your profile.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: semantics.mutedText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({
    required this.message,
    required this.semantics,
    required this.colorScheme,
  });

  final FitnessChatMessage message;
  final AppSemanticColors semantics;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;
    final bg = message.isError
        ? colorScheme.errorContainer
        : isUser
            ? colorScheme.primary
            : semantics.cardBackground;
    final fg = message.isError
        ? colorScheme.onErrorContainer
        : isUser
            ? colorScheme.onPrimary
            : colorScheme.onSurface;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser
                ? null
                : Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.35)),
          ),
          child: Text(message.content, style: theme.textTheme.bodyMedium?.copyWith(color: fg, height: 1.4)),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
            ),
            const SizedBox(width: 10),
            Text('Thinking…', style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
