class ForumDisplayPreferences {
  const ForumDisplayPreferences({
    this.compactCarousel = true,
    this.showForumName = true,
    this.showAccountInfo = false,
    this.showThreadStats = true,
    this.showCarousel = true,
  });

  final bool compactCarousel;
  final bool showForumName;
  final bool showAccountInfo;
  final bool showThreadStats;
  final bool showCarousel;

  ForumDisplayPreferences copyWith({
    bool? compactCarousel,
    bool? showForumName,
    bool? showAccountInfo,
    bool? showThreadStats,
    bool? showCarousel,
  }) => ForumDisplayPreferences(
    compactCarousel: compactCarousel ?? this.compactCarousel,
    showForumName: showForumName ?? this.showForumName,
    showAccountInfo: showAccountInfo ?? this.showAccountInfo,
    showThreadStats: showThreadStats ?? this.showThreadStats,
    showCarousel: showCarousel ?? this.showCarousel,
  );

  factory ForumDisplayPreferences.fromJson(Map<String, dynamic> json) {
    bool read(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    return ForumDisplayPreferences(
      compactCarousel: read('compactCarousel', read('compactHeader', true)),
      showForumName: read('showForumName', true),
      showAccountInfo: read('showAccountInfo', false),
      showThreadStats: read('showThreadStats', true),
      showCarousel: read('showCarousel', true),
    );
  }

  Map<String, dynamic> toJson() => {
    'compactCarousel': compactCarousel,
    'showForumName': showForumName,
    'showAccountInfo': showAccountInfo,
    'showThreadStats': showThreadStats,
    'showCarousel': showCarousel,
  };
}
