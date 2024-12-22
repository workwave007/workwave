import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/savedTechNews.dart';
import 'package:job_apply_hub/Screens/ads/nativeAdWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

class TechNewsSection extends StatefulWidget {
  const TechNewsSection({super.key});

  @override
  _TechNewsSectionState createState() => _TechNewsSectionState();
}
class _TechNewsSectionState extends State<TechNewsSection> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.red[100],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Job Portal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.bookmark_border, color: Colors.black),
                  onPressed: () {
                     Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookmarkedNewsScreen()),
        );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('news')
                  .orderBy('created_at', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerLoader();
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Error loading news.'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No news available.'));
                }

                final newsList = snapshot.data!.docs.map((doc) {
                  return News(
                    image: doc['image'],
                    title: doc['title'],
                    summary: doc['summary'],
                    source: doc['source'],
                    url: doc['url'],
                    postedAt: (doc['created_at'] as Timestamp).toDate(),
                  );
                }).toList();

                return PageView.builder(
                  controller: PageController(viewportFraction: 1, initialPage: 0),
                  scrollDirection: Axis.vertical,
                  itemCount: newsList.length * 3 - 1, // To add space for ads between news items
                  itemBuilder: (context, index) {
                    // Show ad every 2nd index
                    if (index%3==2) {
                      return NativeAdWidget(); // Native ad widget at every 2nd index
                    }

                    // Normal news card
                    final newsIndex = index ~/ 3; // Adjust news index based on ad slots
                    if (newsIndex >= newsList.length) return const SizedBox.shrink();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: NewsCard(news: newsList[newsIndex]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}


Widget _buildShimmerLoader() {
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

class NewsCard extends StatelessWidget {
  final News news;

  const NewsCard({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final BannerAd bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/9214589741', // Replace with your Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    return Container(
      height: 300, // Increased height to accommodate the banner ad at the bottom
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            child: Image.network(
              news.image,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 150,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const Center(child: CircularProgressIndicator());
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(Icons.broken_image, size: 60, color: Colors.grey),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        news.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    IconButton(
                            icon: Icon(
                              Icons.bookmark_border,
                              color: Colors.red,
                            ),
                            onPressed: () async{
                     await SavedNewsManager.saveNews(news);
                           ScaffoldMessenger.of(context).showSnackBar(
                           const SnackBar(content: Text('News saved to bookmarks')),
                             );
                            },
                          ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  news.summary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      news.source,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.redAccent,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await EasyLauncher.url(
                          url: news.url,
                          mode: Mode.inAppBrowser,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Read More',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Banner Ad
          SizedBox(
            height: 50,
            child: AdWidget(ad: bannerAd),
          ),
        ],
      ),
    );
  }
}
class SavedNewsManager {
  // Save a news item to shared_preferences
  static Future<void> saveNews(News news) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNewsJson = prefs.getStringList('savedNews') ?? [];

    // Convert news to a Map and then to a JSON string
    String newsJson = json.encode(news.toMap());

    // Avoid duplicates
    if (!savedNewsJson.contains(newsJson)) {
      savedNewsJson.add(newsJson);
      await prefs.setStringList('savedNews', savedNewsJson);
    }
  }

  // Fetch saved news items from shared_preferences
  static Future<List<News>> fetchSavedNews() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNewsJson = prefs.getStringList('savedNews') ?? [];

    return savedNewsJson
        .map((newsJson) => News.fromMap(json.decode(newsJson)))
        .toList();
  }

  // Remove a news item from the saved news list
  static Future<void> deleteNews(News news) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedNewsJson = prefs.getStringList('savedNews') ?? [];

    // Remove the news item from the list
    savedNewsJson.removeWhere((newsJson) => json.encode(news.toMap()) == newsJson);

    // Save the updated list back to shared_preferences
    await prefs.setStringList('savedNews', savedNewsJson);
  }
}


class News {
  final String image;
  final String title;
  final String summary;
  final String source;
  final String url;
  final DateTime postedAt;

  News({
    required this.image,
    required this.title,
    required this.summary,
    required this.source,
    required this.url,
    required this.postedAt,
  });
   Map<String, dynamic> toMap() {
    return {
      'image': image,
      'title': title,
      'summary': summary,
      'source': source,
      'url': url,
      'postedAt': postedAt.toIso8601String(),
    };
  }

  // Create from Map
  factory News.fromMap(Map<String, dynamic> map) {
    return News(
      image: map['image'],
      title: map['title'],
      summary: map['summary'],
      source: map['source'],
      url: map['url'],
      postedAt: DateTime.parse(map['postedAt']),
    );
  }
}

