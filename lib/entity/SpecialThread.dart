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
  final int? applicants, capacity, approvedApplicants;
  final bool closed;
  ActivityInfo({
    required this.place,
    required this.startsAt,
    required this.endsAt,
    required this.cost,
    required this.status,
    required this.applicants,
    required this.closed,
    this.capacity,
    this.approvedApplicants,
  });

  static bool isAtCapacity(int? capacity, int? approvedApplicants) =>
      capacity != null &&
      capacity > 0 &&
      approvedApplicants != null &&
      approvedApplicants >= capacity;

  bool get full => isAtCapacity(capacity, approvedApplicants);

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
      capacity: int.tryParse(discuzString(json['number'])),
      approvedApplicants: int.tryParse(discuzString(json['applynumber'])),
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
    if (capacity != null) 'number': capacity,
    if (approvedApplicants != null) 'applynumber': approvedApplicants,
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

class DebateInfo {
  const DebateInfo(
    this.affirm,
    this.against,
    this.affirmVotes,
    this.againstVotes,
    this.end,
    this.verdict, {
    this.affirmUsers = const {},
    this.againstUsers = const {},
    this.affirmPosts = const {},
    this.againstPosts = const {},
    this.ended = false,
    this.voted = false,
  });
  final String affirm, against, end, verdict;
  final int? affirmVotes, againstVotes;
  final Set<int> affirmUsers, againstUsers, affirmPosts, againstPosts;
  final bool ended, voted;

  DebateSide? sideForAuthor(int uid) => _side(uid, affirmUsers, againstUsers);

  DebateSide? sideForPost(int pid) => _side(pid, affirmPosts, againstPosts);

  static DebateSide? _side(int id, Set<int> affirm, Set<int> against) {
    if (id <= 0 || affirm.contains(id) == against.contains(id)) return null;
    return affirm.contains(id) ? DebateSide.affirm : DebateSide.against;
  }

  static DebateInfo? parse(Object? value, {int viewer = 0}) {
    final data = discuzMap(value);
    if (data.isEmpty) return null;
    String field(String key) => discuzString(data[key]).trim();
    Set<int> ids(String key, String field, String cached) {
      final rows = data[key];
      return {
        for (final row in rows is List ? rows : discuzMap(rows).values)
          if (discuzInt(discuzMap(row)[field]) case final id when id > 0) id,
        for (final uid in discuzIds(data[cached]).map(discuzInt))
          if (uid > 0) uid,
      };
    }

    bool votedFor(String key) =>
        viewer > 0 && field(key).split(RegExp(r'\s+')).contains('$viewer');
    return DebateInfo(
      field('affirmpoint'),
      field('negapoint'),
      int.tryParse(field('affirmvotes')),
      int.tryParse(field('negavotes')),
      field('endtime'),
      field('umpirepoint'),
      affirmUsers: ids('affirmavatars', 'authorid', 'appAffirmUsers'),
      affirmPosts: ids('affirmavatars', 'pid', 'appAffirmPosts'),
      againstUsers: ids('negaavatars', 'authorid', 'appAgainstUsers'),
      againstPosts: ids('negaavatars', 'pid', 'appAgainstPosts'),
      ended:
          data['appEnded'] == true ||
          (discuzInt(data['dbendtime']) > 0 &&
              discuzInt(data['dbendtime']) <=
                  DateTime.now().millisecondsSinceEpoch ~/ 1000),
      voted:
          data['appVoted'] == true ||
          votedFor('affirmvoterids') ||
          votedFor('negavoterids'),
    );
  }

  Map<String, dynamic> toJson() => {
    'affirmpoint': affirm,
    'negapoint': against,
    'affirmvotes': affirmVotes,
    'negavotes': againstVotes,
    'endtime': end,
    'umpirepoint': verdict,
    'appAffirmUsers': affirmUsers.toList(),
    'appAgainstUsers': againstUsers.toList(),
    'appAffirmPosts': affirmPosts.toList(),
    'appAgainstPosts': againstPosts.toList(),
    'appEnded': ended,
    'appVoted': voted,
  };
}

enum DebateSide {
  neutral(0),
  affirm(1),
  against(2);

  const DebateSide(this.wire);
  final int wire;
}

class TradeItem {
  const TradeItem(
    this.pid,
    this.title,
    this.price,
    this.credit,
    this.stock,
    this.days,
    this.hours,
  );

  final int pid;
  final String title, price, credit;
  final int? stock, days, hours;

  static List<TradeItem> parse(Object? source) => [
    for (final value
        in source is Map
            ? source.values
            : source is List
            ? source
            : const [])
      if (_parseOne(discuzMap(value)) case final item?) item,
  ];

  static TradeItem? _parseOne(Map<String, dynamic> data) {
    final pid = discuzInt(data['pid']);
    final title = discuzString(data['subject']).trim();
    if (pid <= 0 || title.isEmpty) return null;
    int? count(String name) => int.tryParse(discuzString(data[name]));
    String positive(String name) {
      final value = discuzString(data[name]);
      return (double.tryParse(value) ?? 0) > 0 ? value : '';
    }

    return TradeItem(
      pid,
      title,
      positive('price'),
      positive('credit'),
      count('amount'),
      count('expiration'),
      count('expirationhour'),
    );
  }

  Map<String, dynamic> toJson() => {
    'pid': pid,
    'subject': title,
    'price': price,
    'credit': credit,
    'amount': stock,
    'expiration': days,
    'expirationhour': hours,
  };
}
