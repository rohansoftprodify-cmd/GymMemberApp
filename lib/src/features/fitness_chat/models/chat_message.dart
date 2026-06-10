class FitnessChatMessage {
  const FitnessChatMessage({
    required this.role,
    required this.content,
    this.isError = false,
  });

  final String role;
  final String content;
  final bool isError;

  bool get isUser => role == 'user';
  bool get isAssistant => role == 'assistant';

  Map<String, String> toHistoryEntry() => {'role': role, 'content': content};
}
