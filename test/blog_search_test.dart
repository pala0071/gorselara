import 'package:flutter_test/flutter_test.dart';
import 'package:gorselara/domain/blog_search.dart';

void main() {
  test('Turkish query survives URL encoding and is scoped to Blogspot images', () {
    final u = BlogSearch.url('İstanbul & eski fotoğraflar');
    expect(u.queryParameters['q'], 'İstanbul & eski fotoğraflar site:blogspot.com');
    expect(u.queryParameters['as_sitesearch'], 'blogspot.com');
    expect(u.queryParameters['udm'], '2');
  });
  test('Out of scope, malicious suffixes and external intents stay blocked', () {
    for (final url in ['intent://example', 'https://evilblogspot.com/',
      'https://example.com/', 'https://x.blogspot.com.evil.test/', 'javascript:alert(1)']) {
      expect(BlogSearch.allowed(Uri.parse(url)), false);
    }
    expect(BlogSearch.allowed(Uri.parse('https://example.blogspot.com/2026/post.html')), true);
    expect(BlogSearch.allowed(Uri.parse('https://blogger.googleusercontent.com/img/test.jpg')), true);
  });
  test('Google redirect cannot take the user to another source', () {
    expect(BlogSearch.allowed(Uri.https('www.google.com', '/url', {'q': 'https://example.com'})), false);
    expect(BlogSearch.allowed(Uri.https('www.google.com', '/url', {'q': 'https://x.blogspot.com/post'})), true);
  });
  test('Searches on the embedded page regain the Blogspot image restriction without looping', () {
    final u = BlogSearch.restrictedSearch(Uri.https('www.google.com', '/search', {'q': 'orman site:pinterest.com'}));
    expect(u, isNotNull);
    expect(u!.queryParameters['q'], 'orman site:blogspot.com');
    expect(BlogSearch.restrictedSearch(u), isNull);
  });
}
