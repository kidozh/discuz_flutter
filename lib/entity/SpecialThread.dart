import '../utility/discuz_json.dart';

class RewardInfo {
  final String price;
  final int bestPid;
  RewardInfo(this.price, this.bestPid);
  static RewardInfo? parse(Object? value) {
    final json = discuzMap(value);
    if (json.isEmpty) return null;
    final best = json['bestpost'];
    return RewardInfo(
      discuzString(json['rewardprice']),
      best is Map ? discuzInt(best['pid']) : discuzInt(best),
    );
  }

  Map<String, dynamic> toJson() => {'rewardprice': price, 'bestpost': bestPid};
}

class ActivityInfo {
  final String place, startsAt, endsAt, cost, status;
  final int? applicants;
  final bool closed;
  ActivityInfo({
    required this.place,
    required this.startsAt,
    required this.endsAt,
    required this.cost,
    required this.status,
    required this.applicants,
    required this.closed,
  });
  static ActivityInfo? parse(Object? value) {
    final json = discuzMap(value);
    if (json.isEmpty) return null;
    return ActivityInfo(
      place: discuzString(json['place']),
      startsAt: discuzString(json['starttimefrom']),
      endsAt: discuzString(json['starttimeto']),
      cost: discuzString(json['creditcost']),
      status: discuzString(json['status']),
      applicants: json['allapplynum'] == null
          ? null
          : discuzInt(json['allapplynum']),
      closed: discuzPermission(json['closed']) == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'place': place,
    'starttimefrom': startsAt,
    'starttimeto': endsAt,
    'creditcost': cost,
    'status': status,
    'allapplynum': applicants,
    'closed': closed,
  };
}

class ThreadSortInfo {
  final String name;
  final List<ThreadSortOption> options;
  ThreadSortInfo(this.name, this.options);
  static ThreadSortInfo? parse(Object? value) {
    final json = discuzMap(value);
    if (json.isEmpty) return null;
    final raw = json['optionlist'];
    final items = raw is Map
        ? raw.values
        : raw is List
        ? raw
        : const [];
    final options = <ThreadSortOption>[];
    for (final item in items) {
      final entry = discuzMap(item);
      final label = discuzString(entry['title']);
      final content = discuzString(entry['value']);
      if (label.isEmpty || content.isEmpty) continue;
      options.add(
        ThreadSortOption(label, content, discuzString(entry['unit'])),
      );
    }
    return options.isEmpty
        ? null
        : ThreadSortInfo(discuzString(json['threadsortname']), options);
  }

  Map<String, dynamic> toJson() => {
    'threadsortname': name,
    'optionlist': options.map((option) => option.toJson()).toList(),
  };
}

class ThreadSortOption {
  final String title, value, unit;
  ThreadSortOption(this.title, this.value, this.unit);
  Map<String, dynamic> toJson() => {
    'title': title,
    'value': value,
    'unit': unit,
  };
}
