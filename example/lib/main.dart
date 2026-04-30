import 'package:flutter/material.dart';
import 'package:flutter_html_search_highlight/flutter_html_search_highlight.dart';

void main() {
  runApp(const ExampleApp());
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HTML search highlight',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const DemoScreen(),
    );
  }
}

class DemoScreen extends StatelessWidget {
  const DemoScreen({super.key});

  static const _pages = [
    '''
  <h1>Page 1: Introduction</h1>

  <p>Flutter is a modern UI toolkit that enables developers to build high-quality applications for mobile, web, and desktop using a single codebase. Its flexibility and performance make it a popular choice among developers worldwide.</p>

  <p>In many real-world applications, developers need to display rich formatted content. This often comes in the form of HTML, especially when content is fetched from APIs, CMS systems, or external sources.</p>

  <p>However, displaying HTML is only part of the problem. Users also expect to search within that content. Whether it’s documentation, articles, or long descriptions, search plays a critical role in usability.</p>

  <p>This demo showcases how search can be integrated directly into HTML content in Flutter. It allows users to find keywords instantly and highlights them for better visibility.</p>

  <p>As content grows larger, navigation becomes difficult. That’s where pagination and structured rendering help improve the overall user experience.</p>

  <h2>Why This Matters</h2>

  <p>Imagine reading a long article without the ability to search. It becomes frustrating to locate specific information. By combining Flutter, HTML rendering, and search, we can create powerful and user-friendly interfaces.</p>

  <p>This page demonstrates a realistic scenario where content is long enough to require scrolling, making it ideal for testing search and highlight features.</p>
  ''',

    '''
  <h1>Page 2: HTML Rendering</h1>

  <p>Rendering HTML in Flutter allows developers to present structured and styled content without manually building UI components for each element. This is especially useful when working with dynamic content.</p>

  <p>HTML supports a wide range of elements such as headings, paragraphs, lists, links, and images. When rendered properly, it provides a familiar reading experience to users.</p>

  <p>In Flutter, HTML rendering is typically handled using specialized packages that parse and display content efficiently. These tools convert HTML into Flutter widgets.</p>

  <p>However, once HTML is rendered, adding features like search becomes more complex. You need to identify text nodes, match keywords, and visually highlight them.</p>

  <p>This is where search highlighting solutions come into play. They simplify the process by handling parsing, matching, and rendering updates automatically.</p>

  <h2>Handling Large Content</h2>

  <p>Large HTML documents can span multiple screens. Without proper structure, users may feel lost while navigating through content.</p>

  <p>Pagination helps break content into manageable sections, improving readability and performance.</p>
  ''',

    '''
  <h1>Page 3: Search Features</h1>

  <p>Search functionality is one of the most essential features in content-heavy applications. It allows users to quickly locate specific information without manually scanning through the entire page.</p>

  <p>When implemented effectively, search should be fast, accurate, and visually clear. Highlighting matched text ensures users can instantly identify relevant results.</p>

  <p>In this demo, searching for keywords such as Flutter, HTML, or search will highlight all occurrences across the content.</p>

  <p>Additionally, users can navigate between matches using intuitive controls. This improves accessibility and enhances the reading experience.</p>

  <p>Another important aspect is match tracking. Showing how many results are found and which one is currently active gives users better context.</p>

  <h2>User Experience</h2>

  <p>A good search experience is not just about finding results—it’s about guiding the user through them. Smooth navigation and clear highlighting make a significant difference.</p>

  <p>This page demonstrates how search behaves in a realistic content scenario, ensuring that scrolling and navigation feel natural.</p>
  ''',

    '''
  <h1>Page 4: Advanced Usage</h1>

  <p>As applications grow more complex, search functionality must evolve to handle larger datasets and more intricate content structures.</p>

  <p>Advanced implementations include features like automatic scrolling to matches, lazy loading of content, and optimized parsing strategies.</p>

  <p>Performance becomes a key concern when dealing with long HTML documents. Efficient algorithms ensure that search operations remain fast and responsive.</p>

  <p>Another important factor is customization. Developers should be able to modify highlight styles, search behavior, and UI components to match their application design.</p>

  <p>This flexibility allows the integration of search into various use cases, from simple text viewers to complex documentation systems.</p>

  <h2>Best Practices</h2>

  <p>To achieve optimal performance, it is recommended to preprocess HTML content and reuse parsed results whenever possible.</p>

  <p>Proper state management also plays a crucial role in ensuring smooth updates when users perform searches or navigate between results.</p>
  ''',

    '''
  <h1>Page 5: Conclusion</h1>

  <p>This demo highlights the importance of combining Flutter, HTML rendering, and search functionality to create modern, user-friendly applications.</p>

  <p>By enabling users to search within HTML content, we significantly improve usability and accessibility.</p>

  <p>Pagination ensures that large content remains manageable, while highlighting and navigation enhance the overall experience.</p>

  <p>Whether you are building a reader app, documentation viewer, or content-driven platform, integrating search is a valuable addition.</p>

  <p>We encourage you to experiment with different keywords and explore how search behaves across multiple pages.</p>

  <h2>Final Thoughts</h2>

  <p>Flutter continues to evolve as a powerful framework for building cross-platform applications. With the right tools and techniques, developers can deliver rich and interactive experiences.</p>

  <p>Thank you for exploring this demo. Try searching for Flutter, HTML, or search to see the highlighting and navigation in action.</p>
  '''
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flutter Html Search Highlight')),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: HtmlPagedSearchReader(htmlPages: _pages),
      ),
    );
  }
}
