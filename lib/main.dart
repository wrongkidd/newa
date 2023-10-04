import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'NavDrawer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'News Letter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'News Letter'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class NewsItem {
  final String imageUrl;
  final String title;
  final String description;
  final String author;
  final String date;
  final String content;

  NewsItem({
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.author,
    required this.date,
    required this.content,
  });
}

class _MyHomePageState extends State<MyHomePage> {
  List<NewsItem> newsItems = [];
  void _showPopups(BuildContext context, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // The content of the popup goes here
        return AlertDialog(
          title: const Text('Details'),
          content: SingleChildScrollView(
            child: Text(
              content,
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          // Column(
          //   crossAxisAlignment: CrossAxisAlignment.start,
          //   mainAxisSize: MainAxisSize.min,
          //   children: <Widget>[
          //     Text(content),
          //   ],
          // ),
          actions: <Widget>[
            ElevatedButton(
              child: const Text('Close'),
              onPressed: () {
                // Close the popup
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    final response = await http.get(Uri.parse(
        'https://newsapi.org/v2/top-headlines?apiKey=9405687a85974f189099e8123cb146c0&country=in'));

    if (response.statusCode == 200) {
      //print(response.body);
      final List<dynamic> data = jsonDecode(response.body)['articles'];
      //print(data);
      setState(() {
        newsItems = data.map((jsonItem) {
          return NewsItem(
              imageUrl: jsonItem['urlToImage'] ?? '',
              title: jsonItem['title'] ?? '',
              description: jsonItem['description'] ?? '',
              author: jsonItem['author'] ?? '',
              date: jsonItem['publishedAt'] ?? '',
              content: jsonItem['content'] ?? '');
        }).toList();
      });
    } else {
      throw Exception('Failed to load data from API');
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: newsItems.length,
        itemBuilder: (context, index) {
          final item = newsItems[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                _showPopups(context, item.content);
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.network(
                    item.imageUrl,
                    height: 200.0, // Adjust the image height as needed
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // errorBuilder: (context, error, stackTrace) {
                    //   return Icon(Icons.error);
                    // },
                    errorBuilder: (context, error, stackTrace) {
                      //return AssetImage('images/logo.png');

                      return Image.asset('images/no_image.png',
                          width: 300, height: 200, fit: BoxFit.contain);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          item.description,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        SizedBox(height: 8.0),
                        Text(
                          'Author: ${item.author}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                        SizedBox(height: 4.0),
                        Text(
                          'Date: ${item.date}',
                          style: TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
