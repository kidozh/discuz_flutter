class ChevertoUploadResult {
  ChevertoUploadResult({
    required this.rawJson,
    this.statusCode,
    this.statusTxt,
    this.success,
    this.image,
  });

  final int? statusCode;
  final ChevertoSuccessMessage? success;
  final ChevertoUploadedImage? image;
  final String? statusTxt;
  final Map<String, dynamic> rawJson;

  factory ChevertoUploadResult.fromJson(Map<String, dynamic> json) {
    final successJson = _mapValue(json['success']);
    final imageJson = _mapValue(json['image']) ?? _mapValue(json['data']);

    return ChevertoUploadResult(
      rawJson: json,
      statusCode: _intValue(json['status_code']) ?? _intValue(json['status']),
      statusTxt:
          _stringValue(json['status_txt']) ?? _stringValue(json['message']),
      success: successJson == null
          ? null
          : ChevertoSuccessMessage.fromJson(successJson),
      image:
          imageJson == null ? null : ChevertoUploadedImage.fromJson(imageJson),
    );
  }

  Map<String, dynamic> toJson() => rawJson;

  bool get isSuccess {
    final successValue = rawJson['success'];
    if (successValue is bool) {
      return successValue;
    }
    return statusCode == 200 || success?.code == 200;
  }

  String? get imageUrl {
    return image?.bestUrl ?? _firstUrlFromMap(rawJson);
  }

  String? get errorMessage {
    if (isSuccess) {
      return null;
    }
    final errorJson = _mapValue(rawJson['error']);
    return _stringValue(errorJson?['message']) ??
        _stringValue(errorJson?['error']) ??
        statusTxt ??
        _stringValue(rawJson['message']);
  }
}

class ChevertoSuccessMessage {
  ChevertoSuccessMessage({
    this.message,
    this.code,
  });

  final String? message;
  final int? code;

  factory ChevertoSuccessMessage.fromJson(Map<String, dynamic> json) {
    return ChevertoSuccessMessage(
      message: _stringValue(json['message']),
      code: _intValue(json['code']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'code': code,
    };
  }
}

class ChevertoUploadedImage {
  ChevertoUploadedImage({
    required this.rawJson,
    this.filename,
    this.name,
    this.mime,
    this.extension,
    this.url,
    this.urlViewer,
    this.displayUrl,
    this.deleteUrl,
    this.imageDetails,
    this.thumb,
    this.medium,
  });

  final Map<String, dynamic> rawJson;
  final String? filename;
  final String? name;
  final String? mime;
  final String? extension;
  final String? url;
  final String? urlViewer;
  final String? displayUrl;
  final String? deleteUrl;
  final ChevertoImageDetails? imageDetails;
  final ChevertoCompressedImage? thumb;
  final ChevertoCompressedImage? medium;

  factory ChevertoUploadedImage.fromJson(Map<String, dynamic> json) {
    final imageDetailsJson = _mapValue(json['image']);
    final thumbJson = _mapValue(json['thumb']);
    final mediumJson = _mapValue(json['medium']);

    return ChevertoUploadedImage(
      rawJson: json,
      filename: _stringValue(json['filename']),
      name: _stringValue(json['name']),
      mime: _stringValue(json['mime']),
      extension: _stringValue(json['extension']),
      url: _stringValue(json['url']),
      urlViewer: _stringValue(json['url_viewer']),
      displayUrl: _stringValue(json['display_url']),
      deleteUrl: _stringValue(json['delete_url']),
      imageDetails: imageDetailsJson == null
          ? null
          : ChevertoImageDetails.fromJson(imageDetailsJson),
      thumb: thumbJson == null
          ? null
          : ChevertoCompressedImage.fromJson(thumbJson),
      medium: mediumJson == null
          ? null
          : ChevertoCompressedImage.fromJson(mediumJson),
    );
  }

  Map<String, dynamic> toJson() => rawJson;

  String? get bestUrl {
    return url ??
        displayUrl ??
        imageDetails?.url ??
        medium?.url ??
        thumb?.url ??
        urlViewer ??
        _firstUrlFromMap(rawJson);
  }
}

class ChevertoImageDetails {
  ChevertoImageDetails({
    required this.rawJson,
    this.filename,
    this.name,
    this.mime,
    this.extension,
    this.url,
    this.size,
  });

  final Map<String, dynamic> rawJson;
  final String? filename;
  final String? name;
  final String? mime;
  final String? extension;
  final String? url;
  final int? size;

  factory ChevertoImageDetails.fromJson(Map<String, dynamic> json) {
    return ChevertoImageDetails(
      rawJson: json,
      filename: _stringValue(json['filename']),
      name: _stringValue(json['name']),
      mime: _stringValue(json['mime']),
      extension: _stringValue(json['extension']),
      url: _stringValue(json['url']),
      size: _intValue(json['size']),
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}

class ChevertoCompressedImage {
  ChevertoCompressedImage({
    required this.rawJson,
    this.filename,
    this.name,
    this.width,
    this.height,
    this.size,
    this.mime,
    this.extension,
    this.url,
  });

  final Map<String, dynamic> rawJson;
  final String? filename;
  final String? name;
  final int? width;
  final int? height;
  final int? size;
  final String? mime;
  final String? extension;
  final String? url;

  factory ChevertoCompressedImage.fromJson(Map<String, dynamic> json) {
    return ChevertoCompressedImage(
      rawJson: json,
      filename: _stringValue(json['filename']),
      name: _stringValue(json['name']),
      width: _intValue(json['width']),
      height: _intValue(json['height']),
      size: _intValue(json['size']),
      mime: _stringValue(json['mime']),
      extension: _stringValue(json['extension']),
      url: _stringValue(json['url']),
    );
  }

  Map<String, dynamic> toJson() => rawJson;
}

Map<String, dynamic>? _mapValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

int? _intValue(dynamic value) {
  if (value is int) {
    return value;
  }
  if (value is num) {
    return value.toInt();
  }
  if (value is String) {
    return int.tryParse(value);
  }
  return null;
}

String? _stringValue(dynamic value) {
  if (value == null) {
    return null;
  }
  if (value is String) {
    return value;
  }
  return value.toString();
}

String? _firstUrlFromMap(Map<String, dynamic> json) {
  for (final key in ['url', 'display_url', 'url_image', 'image_url']) {
    final value = _stringValue(json[key]);
    if (value != null && value.isNotEmpty) {
      return value;
    }
  }

  for (final key in ['image', 'data', 'medium', 'thumb']) {
    final nestedJson = _mapValue(json[key]);
    final nestedUrl = nestedJson == null ? null : _firstUrlFromMap(nestedJson);
    if (nestedUrl != null && nestedUrl.isNotEmpty) {
      return nestedUrl;
    }
  }
  return null;
}
