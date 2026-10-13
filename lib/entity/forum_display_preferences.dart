class ForumDisplayPreferences {
  const ForumDisplayPreferences({
    this.compactHeader = true,
    this.showForumName = true,
    this.showAccountInfo = false,
    this.showThreadStats = true,
    this.showCarousel = true,
  });

  final bool compactHeader;
  final bool showForumName;
  final bool showAccountInfo;
  final bool showThreadStats;
  final bool showCarousel;

  ForumDisplayPreferences copyWith({
    bool? compactHeader,
    bool? showForumName,
    bool? showAccountInfo,
    bool? showThreadStats,
    bool? showCarousel,
  }) => ForumDisplayPreferences(
    compactHeader: compactHeader ?? this.compactHeader,
    showForumName: showForumName ?? this.showForumName,
    showAccountInfo: showAccountInfo ?? this.showAccountInfo,
    showThreadStats: showThreadStats ?? this.showThreadStats,
    showCarousel: showCarousel ?? this.showCarousel,
  );

  factory ForumDisplayPreferences.fromJson(Map<String, dynamic> json) {
    bool read(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    return ForumDisplayPreferences(
      compactHeader: read('compactHeader', true),
      showForumName: read('showForumName', true),
      showAccountInfo: read('showAccountInfo', false),
      showThreadStats: read('showThreadStats', true),
      showCarousel: read('showCarousel', true),
    );
  }

  Map<String, dynamic> toJson() => {
    'compactHeader': compactHeader,
    'showForumName': showForumName,
    'showAccountInfo': showAccountInfo,
    'showThreadStats': showThreadStats,
    'showCarousel': showCarousel,
  };
}
