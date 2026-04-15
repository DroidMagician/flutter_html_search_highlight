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
    '<h1>Chapter 1</h1><p>This week\'s topic is <strong>Flutter</strong> '
        'and rendering HTML.</p>',
    '<h1>Chapter 2</h1><p>We still discuss Flutter and search highlights.</p>',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('flutter_html_search_highlight')),
      body: const Padding(
        padding: EdgeInsets.all(8),
        child: HtmlPagedSearchReader(htmlPages: _pages),
      ),
    );
  }
}
