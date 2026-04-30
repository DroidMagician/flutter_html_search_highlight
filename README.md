# flutter_html_search_highlight

🔥 **Highlight and navigate search results inside HTML content in Flutter — with built-in UI and zero setup.**

Search across HTML pages, highlight matches with `<mark>`, and give users smooth navigation (next/previous) without writing custom parsing logic.

---

## 🎬 Demo

Instantly search, highlight, and navigate across HTML content:

### Single Page Search
![Single Page Demo](https://raw.githubusercontent.com/DroidMagician/flutter_html_search_highlight/main/assets/single_page_demo.gif)

### Multi Page Search
![Multi Page Demo](https://raw.githubusercontent.com/DroidMagician/flutter_html_search_highlight/main/assets/multi_page_demo.gif)

## ✨ Features

* 🔍 Search plain text inside HTML content
* 🎯 Highlight matches using `<mark>` tags
* 📄 Supports multi-page HTML content
* ⏭️ Navigate between matches (next / previous)
* 📊 Match count per page
* 🧭 Scroll positioning for matches
* 🎨 Fully customizable UI (search bar, styles, icons)
* ⚡ Built on `flutter_html` + HTML parser

---

## 🚀 Quick Start

```dart
import 'package:flutter_html_search_highlight/flutter_html_search_highlight.dart';

HtmlPagedSearchReader(
  htmlContent: "<p>Hello Flutter world</p>",
)
```

That’s it. No extra setup needed.

---

## 📦 Installation

```yaml
dependencies:
  flutter_html_search_highlight: ^0.1.0
```

---

## 💡 Why use this?

Instead of building everything manually on top of `flutter_html`, this package gives you:

✅ Built-in search UI
✅ Automatic highlighting
✅ Match navigation (next / previous)
✅ Multi-page support
✅ Scroll-to-match logic

All without writing complex parsing or state management.

---

## 🧠 Core API (Custom UI)

Use this if you want full control over UI.

```dart
final cleaned = pages.map(HtmlSearchHighlighter.cleanHtml).toList();

final result = HtmlSearchHighlighter.searchPages(cleaned, "week's");

// Access results
result.displayPages;
result.matches;
result.matchesPerPage;
```

### Scroll alignment helper

```dart
final offset = HtmlSearchHighlighter.scrollOffsetForMatch(
  sourcePageHtml: cleaned[page],
  keyword: keyword,
  matchIndex: 0,
  maxScrollExtent: controller.position.maxScrollExtent,
);
```

---

## 📖 Built-in Paged Reader

### Multi-page HTML

```dart
HtmlPagedSearchReader(
  htmlPages: const [
    '<p>First page mentions <b>Flutter</b>.</p>',
    '<p>Second page also talks about Flutter.</p>',
  ],
)
```

### Single HTML content

```dart
HtmlPagedSearchReader(
  htmlContent: '<h1>One page</h1><p>Search me.</p>',
)
```

---

## 🔄 Content Modes

Force behavior explicitly:

```dart
HtmlPagedSearchReader(
  htmlPages: manySections,
  contentMode: HtmlContentMode.singlePage,
  singlePageSeparator: '<hr/>',
)
```

```dart
HtmlPagedSearchReader(
  htmlContent: myHtml,
  contentMode: HtmlContentMode.multiPage,
)
```

---

## 🎨 Customization

### Highlight & styles

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
  highlightColor: Colors.orangeAccent,
  markStyle: Style(backgroundColor: Colors.lime),
  htmlStyles: {
    'h1': Style(fontSize: FontSize(22)),
  },
)
```

---

### Customize search UI

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
  searchFieldBuilder: (context, controller, onChanged, keyword) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: const InputDecoration(hintText: 'Search...'),
    );
  },
)
```

---

### Customize navigation UI

```dart
HtmlPagedSearchReader(
  htmlPages: myPages,
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
        IconButton(onPressed: onPrevious, icon: Icon(Icons.expand_less)),
        IconButton(onPressed: onNext, icon: Icon(Icons.expand_more)),
      ],
    );
  },
)
```

---

## 📁 Example

Check the `/example` folder for a complete working demo.

---

## ⚙️ Tips

* Call `cleanHtml()` once for better performance
* Set `cleanPagesOnLoad: false` if already cleaned
* Use pagination for large HTML content

---

## 🧾 Changelog

### 0.1.0

✨ Initial release

* HTML search & highlight
* Paged reader with navigation
* Match tracking and scroll support

---

## 🤝 Contributing

Contributions, issues, and feature requests are welcome!

---

## 📄 License

This package is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

## ⭐ Support

If this package helps you, consider giving it a ⭐ on GitHub and a 👍 on pub.dev.
