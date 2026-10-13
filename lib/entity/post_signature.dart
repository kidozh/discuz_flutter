enum PostSignatureStyle { none, app, appAndDevice, device, custom }

/// The style is stored separately so custom text can never select a preset.
class PostSignature {
  const PostSignature({
    this.style = PostSignatureStyle.app,
    this.customText = '',
  });

  final PostSignatureStyle style;
  final String customText;

  bool get includesApp =>
      style == PostSignatureStyle.app ||
      style == PostSignatureStyle.appAndDevice;
  bool get includesDevice =>
      style == PostSignatureStyle.device ||
      style == PostSignatureStyle.appAndDevice;

  PostSignature withStyle(PostSignatureStyle value) =>
      PostSignature(style: value, customText: customText);

  static PostSignature fromLegacy(String? value) => switch (value) {
    null || 'USE_APP_SIGNATURE' => const PostSignature(),
    '' => const PostSignature(style: PostSignatureStyle.none),
    'USE_DEVICE_SIGNATURE' => const PostSignature(
      style: PostSignatureStyle.device,
    ),
    _ => PostSignature(style: PostSignatureStyle.custom, customText: value),
  };

  factory PostSignature.fromJson(Map<String, dynamic> json) {
    final style = PostSignatureStyle.values
        .where((value) => value.name == json['style'])
        .firstOrNull;
    return PostSignature(
      // Unknown styles must not opt a user into publishing device information.
      style: style ?? PostSignatureStyle.none,
      customText: json['customText'] is String
          ? json['customText'] as String
          : '',
    );
  }

  Map<String, dynamic> toJson() => {
    'style': style.name,
    'customText': customText,
  };
}
