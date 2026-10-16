class AiChatTurn {
  const AiChatTurn({required this.question, required this.answer});

  final String question;
  final String answer;

  Map<String, dynamic> toJson() => {'question': question, 'answer': answer};

  factory AiChatTurn.fromJson(Map<String, dynamic> json) => AiChatTurn(
    question: json['question'] as String,
    answer: json['answer'] as String,
  );
}

class AiConversation {
  AiConversation({
    required this.id,
    required this.updatedAt,
    this.instructions = '',
    this.ruleName,
    this.turns = const [],
  });

  final String id;
  final DateTime updatedAt;
  final String instructions;
  final String? ruleName;
  final List<AiChatTurn> turns;

  String get title => turns.isEmpty
      ? ''
      : String.fromCharCodes(turns.first.question.runes.take(60));

  AiConversation append(AiChatTurn turn) => AiConversation(
    id: id,
    updatedAt: DateTime.now(),
    instructions: instructions,
    ruleName: ruleName,
    turns: [...turns, turn],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'updatedAt': updatedAt.toIso8601String(),
    'instructions': instructions,
    'ruleName': ruleName,
    'turns': turns.map((turn) => turn.toJson()).toList(),
  };

  factory AiConversation.fromJson(Map<String, dynamic> json) => AiConversation(
    id: json['id'] as String,
    updatedAt: DateTime.parse(json['updatedAt'] as String),
    instructions: json['instructions'] as String,
    ruleName: json['ruleName'] as String?,
    turns: (json['turns'] as List)
        .map((turn) => AiChatTurn.fromJson(Map<String, dynamic>.from(turn)))
        .toList(),
  );
}
