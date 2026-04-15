/// Search and highlight plain text inside HTML strings, with an optional
/// paged reader built on [flutter_html](https://pub.dev/packages/flutter_html).
library;

export 'package:flutter_html/flutter_html.dart' show Html, Style, FontSize;

export 'src/html_multi_page_search_result.dart';
export 'src/html_page_highlight.dart';
export 'src/html_search_highlighter.dart';
export 'src/match_location.dart';
export 'src/widgets/html_paged_search_reader.dart';
