Map<String, dynamic> asMap(dynamic value) => value is Map ? Map<String, dynamic>.from(value) : {};
List<dynamic> asList(dynamic value) => value is List ? value : [];
String str(dynamic value) => value?.toString() ?? '';
int? integer(dynamic value) => value is num ? value.toInt() : int.tryParse(str(value));
String plain(dynamic value) => str(value).replaceAll(RegExp('<[^>]*>'), '')
    .replaceAll('&amp;', '&').replaceAll('&quot;', '"').replaceAll('&#39;', "'")
    .replaceAll('&lt;', '<').replaceAll('&gt;', '>').trim();
bool webUrl(String value) {
  final u = Uri.tryParse(value);
  return u != null && u.scheme == 'https' && u.host.isNotEmpty && u.userInfo.isEmpty;
}
String referral(String value) {
  final u = Uri.tryParse(value);
  if (u == null) return value;
  return u.replace(queryParameters: {...u.queryParameters,
    'utm_source': 'gorselara', 'utm_medium': 'referral'}).toString();
}
