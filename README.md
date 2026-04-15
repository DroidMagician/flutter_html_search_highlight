# flutter_html_search_highlight

Search plain text inside HTML fragments, wrap hits with `<mark>`, and optionally show a **paged reader** with search, match counts, and prev/next navigation—built on [`flutter_html`](https://pub.dev/packages/flutter_html) and the [`html`](https://pub.dev/packages/html) parser.

## Install

```yaml
dependencies:
  flutter_html_search_highlight: ^0.1.0
```

## Usage

### 1. Core API (any UI)

Clean HTML once when you load it, then run a search across pages:

```dart
import 'package:flutter_html_search_highlight/flutter_html_search_highlight.dart';

final cleaned = pages.map(HtmlSearchHighlighter.cleanHtml).toList();
final result = HtmlSearchHighlighter.searchPages(cleaned, "week's");

// result.displayPages — HTML with <mark>…</mark>
// result.matches       — MatchLocation(pageIndex, matchIndex)
// result.matchesPerPage
```

Helper for approximate scroll alignment (same idea as mapping match index to a fraction of `maxScrollExtent`):

```dart
final offset = HtmlSearchHighlighter.scrollOffsetForMatch(
  sourcePageHtml: cleaned[page],
  keyword: keyword,
  matchIndex: 0,
  maxScrollExtent: controller.position.maxScrollExtent,
);
```

### 2. Built-in paged reader

```dart
import 'package:flutter/material.dart';
import 'package:flutter_html_search_highlight/flutter_html_search_highlight.dart';

HtmlPagedSearchReader(
  htmlPages: const [
    '<p>First page mentions <b>Flutter</b> and HTML.</p>',
    '<p>Second page also talks about Flutter.</p>',
  ],
  // optional callback is still available
  onPageChanged: (i) => debugPrint('page $i'),
)
```

Single HTML string:

```dart
HtmlPagedSearchReader(
  htmlContent: '<h1>One page</h1><p>Search me.</p>',
)
```

Use one flag to force behavior:

```dart
HtmlPagedSearchReader(
  htmlPages: manySections,
  contentMode: HtmlContentMode.singlePage, // merge into one page
  singlePageSeparator: '<hr/>',
)
```

```dart
HtmlPagedSearchReader(
  htmlContent: myOneHtmlString,
  contentMode: HtmlContentMode.multiPage, // treated as list of 1 page
)
```

Customize `<mark>` and other tags via [flutter_html `Style`](https://pub.dev/packages/flutter_html):

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
  highlightColor: Colors.orangeAccent,
  markStyle: Style(backgroundColor: Colors.lime),
  htmlStyles: {
    'h1': Style(fontSize: FontSize(22), fontWeight: FontWeight.w600),
  },
)
```

Set `cleanPagesOnLoad: false` if you already called `HtmlSearchHighlighter.cleanHtml` yourself.

### 3. Customize search bar, counter, and arrows

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
  highlightColor: Colors.amber, // quick highlight color
  searchTextStyle: const TextStyle(fontSize: 14),
  searchHintStyle: const TextStyle(color: Colors.grey),
  counterTextStyle: const TextStyle(fontWeight: FontWeight.w700),
  previousMatchIcon: const Icon(Icons.arrow_upward),
  nextMatchIcon: const Icon(Icons.arrow_downward),
)
```

For complete control, replace the widgets:

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
  searchFieldBuilder: (context, controller, onChanged, keyword) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(hintText: 'Type keyword'),
    );
  },
  matchNavigationBuilder: (
    context,
    currentMatch,
    totalMatches,
    onPrevious,
    onNext,
  ) {
    return Row(
      children: [
        Text('$currentMatch/$totalMatches'),
        IconButton(onPressed: onPrevious, icon: const Icon(Icons.expand_less)),
        IconButton(onPressed: onNext, icon: const Icon(Icons.expand_more)),
      ],
    );
  },
)
```

## Publishing checklist

1. Replace the placeholder `homepage` / `repository` / `issue_tracker` URLs in `pubspec.yaml` with your real GitHub (or other) links.
2. Run `dart analyze` and `flutter test`.
3. Run `dart pub publish --dry-run` and fix any reported issues.

## License

See [LICENSE](LICENSE).
