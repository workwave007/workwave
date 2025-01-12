import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
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
  List<News> newsList = [];
  DocumentSnapshot? lastDocument;
  bool isLoading = false;
  bool hasMore = true;
  final int pageSize = 10;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.9, initialPage: 0);
    _pageController.addListener(_pageScrollListener);
    _fetchNews(); // Initial fetch
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchNews() async {
    if (isLoading || !hasMore) return;

    setState(() {
      isLoading = true;
    });

    Query query = FirebaseFirestore.instance
        .collection('news')
        .orderBy('created_at', descending: true)
        .limit(pageSize);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument!);
    }

    try {
      QuerySnapshot snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        lastDocument = snapshot.docs.last; // Update the last fetched document
        newsList.addAll(snapshot.docs.map((doc) {
          return News(
            image: doc['image'],
            title: doc['title'],
            summary: doc['summary'],
            source: doc['source'],
            url: doc['url'],
            postedAt: (doc['created_at'] as Timestamp).toDate(),
          );
        }).toList());
        if (snapshot.docs.length < pageSize) {
          hasMore = false; // No more news to fetch
        }
      } else {
        hasMore = false; // No more news to fetch
      }
    } catch (error) {
      print('Error fetching news: $error');
    }

    setState(() {
      isLoading = false;
    });
  }

  void _pageScrollListener() {
    if (_pageController.position.pixels >=
            _pageController.position.maxScrollExtent - 100 &&
        hasMore &&
        !isLoading) {
      _fetchNews(); // Fetch the next page of news
    }
  }

  @override
Widget build(BuildContext context) {
  final screenHeight = MediaQuery.of(context).size.height;
  final cardHeight = screenHeight * 0.8;

  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      centerTitle: true,
      backgroundColor: Colors.red[100],
      title: const Text(
        'Tech News',
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ),
    body: newsList.isEmpty && isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Colors.blue),
          )
        : PageView.builder(
            controller: _pageController,
            scrollDirection: Axis.vertical,
            itemCount: newsList.length + (hasMore ? 1 : 0), // Add extra page only if there is more to load
            itemBuilder: (context, index) {
              if (index < newsList.length) {
                // Display news cards and ads
                if (index % 3 == 2) {
                  return  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NativeAdWidget(),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: NewsCard(
                      news: newsList[index],
                      cardHeight: cardHeight,
                    ),
                  );
                }
              } else {
                // Show loading indicator only if there are more news to load
                return hasMore
                    ? const Center(
                        child: CircularProgressIndicator(color: Colors.blue),
                      )
                    : const SizedBox(); // No more news, show an empty widget
              }
            },
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
class NewsCard extends StatefulWidget {
  final News news;
  final double cardHeight;

  const NewsCard({
    super.key,
    required this.news,
    required this.cardHeight,
  });

  @override
  State<NewsCard> createState() => _NewsCardState();
}

class _NewsCardState extends State<NewsCard> with WidgetsBindingObserver{

  FlutterTts flutterTts = FlutterTts();
  bool isWidgetVisible = false;
  bool speakerIsOn = false;
  @override
  void initState() {
    super.initState();
   
    flutterTts.setLanguage("en-US");
    flutterTts.setSpeechRate(0.5);
     WidgetsBinding.instance.addObserver(this);
     // Adjust speech rate as needed
  }
   @override
  void dispose() {
    flutterTts.stop(); // Stop TTS when widget is disposed
    WidgetsBinding.instance.removeObserver(this); // Remove observer
    super.dispose();
  }

  // Called when the app lifecycle state changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      flutterTts.stop(); // Stop TTS if the app is paused
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Track visibility manually if needed
    if (!isWidgetVisible) {
      flutterTts.stop(); // Stop TTS if the widget is not visible
    }
  }

  void _onVisibilityChanged(bool isVisible) {
    setState(() {
      isWidgetVisible = isVisible;
      if (!isWidgetVisible) {
        flutterTts.stop(); // Stop TTS if widget becomes invisible
      }
    });
  }

  

  @override
  Widget build(BuildContext context) {
    final BannerAd bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-6846718920811344/7291118535', // Replace with your Banner Ad Unit ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    )..load();

    return Container(
      height: widget.cardHeight, // Dynamic height
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
          // Adjust the image height dynamically
          Stack(
  children: [
    ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Image.network(
        widget.news.image,
        fit: BoxFit.cover,
        width: double.infinity,
        height: widget.cardHeight * 0.25, // Image takes 40% of the card height
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
    Positioned(
      bottom: 10, // Adjust the distance from the bottom of the image
      right: 10,  // Adjust the distance from the right of the image
      child: GestureDetector(
        onTap: () {
          if (speakerIsOn) {
            flutterTts.stop(); // Stops the speech
          } else {
            flutterTts.speak("Title " + widget.news.title + " Summary " + widget.news.summary);
          }
          setState(() {
            speakerIsOn = !speakerIsOn; // Toggle the speaker state
          });
        },
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
          
      color: Colors.red,
      borderRadius: BorderRadius.circular(30),
      
    ),
          child: Icon(
            speakerIsOn ?  Icons.volume_off:Icons.volume_up ,
            color: Colors.white,
          ),
        ),
      ),
    ),
  ],
),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
          
                   Text(
                        
                        widget.news.title,
                        
                        style: TextStyle(
                          fontSize: widget.cardHeight * 0.025 ,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                       
                      ),
                   
                const SizedBox(height: 8),
                Text(
                  widget.news.summary,
                  style: TextStyle(
                    fontSize: widget.cardHeight * 0.023,
                    color: Colors.grey[700],
                  ),
                  
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.news.source,
                      style:  TextStyle(
                        fontSize: widget.cardHeight * 0.023,
                        color: Colors.redAccent,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await EasyLauncher.url(
                          url: widget.news.url,
                          mode: Mode.inAppBrowser,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text(
                        'Read More',
                        style: TextStyle(
                          fontSize:widget.cardHeight * 0.023,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Banner Ad at the bottom
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

