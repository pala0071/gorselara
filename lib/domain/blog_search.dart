class BlogSearch {
  static Uri url(String query) => Uri.https('www.google.com', '/search', {
    'q': '${cleanQuery(query)} site:blogspot.com',
    'as_sitesearch': 'blogspot.com', 'udm': '2', 'hl': 'tr',
  });

  static String cleanQuery(String query) => query
      .replaceAll(RegExp(r'-?site:\S+', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ').trim();

  static bool inDomain(String host, String domain) =>
      host == domain || host.endsWith('.$domain');

  static bool allowed(Uri uri) {
    if (uri.scheme != 'https') return false;
    final h = uri.host.toLowerCase();
    if (h == 'www.google.com' || h == 'google.com' || h == 'consent.google.com') {
      if (uri.path == '/url') {
        final target = uri.queryParameters['url'] ?? uri.queryParameters['q'];
        if (target != null) {
          final destination = Uri.tryParse(target);
          return destination != null && isBlogOrImage(destination);
        }
      }
      return true;
    }
    return isBlogOrImage(uri);
  }

  static bool isBlogOrImage(Uri uri) => uri.scheme == 'https' &&
      ['blogspot.com', 'blogspot.com.tr', 'blogger.com', 'googleusercontent.com']
          .any((domain) => inDomain(uri.host.toLowerCase(), domain));

  // Keep searches made through Google's own page restricted as well.
  static Uri? restrictedSearch(Uri uri) {
    if (!['google.com', 'www.google.com'].contains(uri.host) || uri.path != '/search') return null;
    if (uri.queryParameters['as_sitesearch'] == 'blogspot.com' &&
        (uri.queryParameters['udm'] == '2' || uri.queryParameters['tbm'] == 'isch')) return null;
    final params = Map<String, String>.from(uri.queryParameters);
    params['q'] = '${cleanQuery(params['q'] ?? '')} site:blogspot.com';
    params['as_sitesearch'] = 'blogspot.com';
    params['udm'] = '2';
    params.remove('tbm');
    return uri.replace(scheme: 'https', queryParameters: params);
  }
}
