import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../models/article_model.dart';

class GlobalNews extends StatefulWidget {
  const GlobalNews({super.key});

  @override
  State<GlobalNews> createState() => _GlobalNewsState();
}

class _GlobalNewsState extends State<GlobalNews> {
  List<Article> articles = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    //const apiKey = 'u1LgaOQJEkHRL5VvjUMRN0uZawHLYq';
    const apiKey = '9f9229fce07f4b69ab37d3d2a5ae5094';

    // const apiUrl =
    //     'https://newsapi.in/newsapi/news.php?key=u1LgaOQJEkHRL5VvjUMRN0uZawHLYq&category=hindi_state';
    const apiUrl =
        'https://newsapi.org/v2/everything?q=eco&sortBy=popularity&apiKey=9f9229fce07f4b69ab37d3d2a5ae5094';

    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      print('jsonData: $jsonData');

      setState(() {
        articles = (jsonData['articles'] as List)
            .map((articleJson) => Article.fromMap(articleJson))
            .toList();
      });
      print('articles: $articles');
    } else {
      print('HTTP error ${response.statusCode}: ${response.reasonPhrase}');
      throw Exception('failed to load news');
    }
  }

  void launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).accentColor,
      appBar: AppBar(
        title: const Text('Sustainability News'),
      ),
      body: articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: articles.length,
              itemBuilder: (context, index) {
                final article = articles[index];
                return Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SingleChildScrollView(
                      child: Card(
                        color: Theme.of(context).accentColor,
                        shadowColor: Theme.of(context).primaryColorDark,
                        child: ListTile(
                          leading: (article.urlToImage != null &&
                                  article.urlToImage.isNotEmpty)
                              ? SizedBox(
                                  height: 70,
                                  width: 70,
                                  child: Image.network(
                                    article.urlToImage,
                                    scale: 1.0,
                                  ),
                                )
                              : const Icon(Icons.image_not_supported),
                          title: Text(
                            article.title,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onTap: () => launchUrl(article.url),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
