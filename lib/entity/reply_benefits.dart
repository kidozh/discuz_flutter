import '../utility/discuz_json.dart';

class ReplyCreditRule {
  const ReplyCreditRule({
    required this.amount,
    required this.creditType,
    required this.remaining,
    required this.perMember,
    required this.chance,
  });

  final int amount;
  final int creditType;
  final int? remaining;
  final int perMember;
  final int chance;

  static ReplyCreditRule? parse(Object? value) {
    final data = discuzMap(value);
    if (data.isEmpty) return null;
    final remaining = double.tryParse(discuzString(data['remaining']));
    return ReplyCreditRule(
      amount: discuzInt(data['extcredits']),
      creditType: discuzInt(data['extcreditstype']),
      remaining: remaining != null && remaining.isFinite && remaining >= 0
          ? remaining.floor()
          : null,
      perMember: discuzInt(data['membertimes']),
      chance: discuzInt(data['random']),
    );
  }

  Map<String, dynamic> toJson() => {
    'extcredits': amount,
    'extcreditstype': creditType,
    'remaining': remaining,
    'membertimes': perMember,
    'random': chance,
  };
}

class RushReplyInfo {
  const RushReplyInfo({
    required this.startsAt,
    required this.endsAt,
    required this.rewardFloors,
    required this.stopFloor,
    required this.perMember,
    required this.creditLimit,
    required this.creditName,
    required this.timerType,
    required this.deadline,
  });

  final String startsAt;
  final String endsAt;
  final String rewardFloors;
  final int stopFloor;
  final int perMember;
  final String creditLimit;
  final String creditName;
  final String timerType;
  final DateTime? deadline;

  static RushReplyInfo? parse(Object? value) {
    final data = discuzMap(value);
    if (data.isEmpty) return null;
    final seconds = discuzInt(data['timer']);
    final savedDeadline = DateTime.tryParse(discuzString(data['deadline']));
    final limit = discuzString(data['creditlimit']);
    return RushReplyInfo(
      startsAt: discuzString(data['starttimefrom']),
      endsAt: discuzString(data['starttimeto']),
      rewardFloors: discuzString(data['rewardfloor']),
      stopFloor: discuzInt(data['stopfloor']),
      perMember: discuzInt(data['replylimit']),
      creditLimit: limit == '-996' ? '' : limit,
      creditName: discuzString(data['creditlimit_title']),
      timerType: discuzString(data['timertype']),
      deadline:
          savedDeadline ??
          (seconds > 0 && seconds <= 315576000
              ? DateTime.now().add(Duration(seconds: seconds))
              : null),
    );
  }

  Map<String, dynamic> toJson() => {
    'starttimefrom': startsAt,
    'starttimeto': endsAt,
    'rewardfloor': rewardFloors,
    'stopfloor': stopFloor,
    'replylimit': perMember,
    'creditlimit': creditLimit,
    'creditlimit_title': creditName,
    'timertype': timerType,
    'deadline': deadline?.toIso8601String(),
  };
}
