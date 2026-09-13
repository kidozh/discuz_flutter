/// Scalar coercions for Discuz's string-valued API and numeric site variants.
String discuzString(Object? value) =>
    value is String || value is num ? value.toString() : '';

int discuzInt(Object? value) => value is num && value.isFinite
    ? value.toInt()
    : int.tryParse(discuzString(value)) ?? 0;

bool? discuzPermission(Object? value) {
  if (value == true || value == 1 || value == '1') return true;
  if (value == false || value == 0 || value == '0') return false;
  return null;
}

Map<String, dynamic> discuzMap(Object? value) => value is Map
    ? value.map((key, value) => MapEntry(key.toString(), value))
    : <String, dynamic>{};

List<String> discuzIds(Object? value) =>
    (value is Map
            ? value.values
            : value is List
            ? value
            : const [])
        .map(discuzString)
        .where((id) => id.isNotEmpty)
        .toList();

/// Normalizes only scalar fields. Nested payloads retain their own schema.
Map<String, dynamic> discuzScalars(Map<String, dynamic> json) => json.map(
  (key, value) => MapEntry(key, value is num ? value.toString() : value),
);
