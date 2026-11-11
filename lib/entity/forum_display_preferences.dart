enum ForumImageCookiePolicy { always, sameSite, never }

class ForumDisplayPreferences {
  const ForumDisplayPreferences({
    this.mergeHomeNavigation = false,
    this.compactCarousel = true,
    this.showForumName = true,
    this.showAccountInfo = false,
    this.showThreadStats = true,
    this.showCarousel = true,
    this.imageCookiePolicy = ForumImageCookiePolicy.sameSite,
  });

  final bool mergeHomeNavigation;
  final bool compactCarousel;
  final bool showForumName;
  final bool showAccountInfo;
  final bool showThreadStats;
  final bool showCarousel;
  final ForumImageCookiePolicy imageCookiePolicy;

  ForumDisplayPreferences copyWith({
    bool? mergeHomeNavigation,
    bool? compactCarousel,
    bool? showForumName,
    bool? showAccountInfo,
    bool? showThreadStats,
    bool? showCarousel,
    ForumImageCookiePolicy? imageCookiePolicy,
  }) => ForumDisplayPreferences(
    mergeHomeNavigation: mergeHomeNavigation ?? this.mergeHomeNavigation,
    compactCarousel: compactCarousel ?? this.compactCarousel,
    showForumName: showForumName ?? this.showForumName,
    showAccountInfo: showAccountInfo ?? this.showAccountInfo,
    showThreadStats: showThreadStats ?? this.showThreadStats,
    showCarousel: showCarousel ?? this.showCarousel,
    imageCookiePolicy: imageCookiePolicy ?? this.imageCookiePolicy,
  );

  factory ForumDisplayPreferences.fromJson(Map<String, dynamic> json) {
    bool read(String key, bool fallback) =>
        json[key] is bool ? json[key] as bool : fallback;
    return ForumDisplayPreferences(
      // The former compactHeader default was true. Restoring the feature must
      // require a fresh opt-in rather than reactivating that legacy default.
      mergeHomeNavigation: read('mergeHomeNavigation', false),
      compactCarousel: read('compactCarousel', read('compactHeader', true)),
      showForumName: read('showForumName', true),
      showAccountInfo: read('showAccountInfo', false),
      showThreadStats: read('showThreadStats', true),
      showCarousel: read('showCarousel', true),
      imageCookiePolicy: switch (json['imageCookiePolicy']) {
        'always' => ForumImageCookiePolicy.always,
        'sameSite' => ForumImageCookiePolicy.sameSite,
        'never' => ForumImageCookiePolicy.never,
        _ =>
          read('useForumCookiesForImages', true)
              ? ForumImageCookiePolicy.sameSite
              : ForumImageCookiePolicy.never,
      },
    );
  }

  Map<String, dynamic> toJson() => {
    'mergeHomeNavigation': mergeHomeNavigation,
    'compactCarousel': compactCarousel,
    'showForumName': showForumName,
    'showAccountInfo': showAccountInfo,
    'showThreadStats': showThreadStats,
    'showCarousel': showCarousel,
    'imageCookiePolicy': imageCookiePolicy.name,
  };
}
