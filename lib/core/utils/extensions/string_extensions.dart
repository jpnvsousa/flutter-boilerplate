extension StringX on String {
  /// Capitalize first letter only.
  String get capitalized =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  /// Capitalize each word.
  String get titleCase => split(' ').map((w) => w.capitalized).join(' ');

  /// Returns null if empty, otherwise the string itself.
  String? get nullIfEmpty => isEmpty ? null : this;

  /// True if this is a valid email address.
  bool get isValidEmail => RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      ).hasMatch(this);

  /// Truncates to [maxLength] chars, adding ellipsis if needed.
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }
}

extension NullableStringX on String? {
  /// Returns true if null or empty.
  bool get isNullOrEmpty => this == null || this!.isEmpty;

  /// Returns the string or a fallback if null/empty.
  String orDefault(String fallback) => isNullOrEmpty ? fallback : this!;
}
