import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/savedNewsCard.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/techNewsSection.dart';
import 'package:job_apply_hub/Screens/ads/nativeAdWidget.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkedNewsScreen extends StatefulWidget {
  const BookmarkedNewsScreen({super.key});

  @override
  _BookmarkedNewsScreenState createState() => _BookmarkedNewsScreenState();
}

class _BookmarkedNewsScreenState extends State<BookmarkedNewsScreen> {
  late Future<List<News>> _bookmarkedNewsFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedNewsFuture = getBookmarkedNews();
  }

  Future<List<News>> getBookmarkedNews() async {
    return await SavedNewsManager.fetchSavedNews();
  }

  void _reloadSavedNews() {
    setState(() {
      _bookmarkedNewsFuture = SavedNewsManager.fetchSavedNews();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarked News'),
      ),
      body: FutureBuilder<List<News>>(
        future: _bookmarkedNewsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No bookmarked news'),
            );
          }

          final bookmarkedNews = snapshot.data!;

          return PageView.builder(
  scrollDirection: Axis.vertical,
  controller: PageController(viewportFraction: 1, initialPage: 0),
  itemCount: bookmarkedNews.length + (bookmarkedNews.length ~/ 3), // Add extra items for ads
  itemBuilder: (context, index) {
    // Calculate whether this index is for an ad or a news card
    if ((index + 1) % 4 == 0) {
      // Show the NativeAdWidget at every third position
      return NativeAdWidget();
    } else {
      // Adjust index to account for the ads
      final adjustedIndex = index - (index ~/ 4);
      final news = bookmarkedNews[adjustedIndex];
      return SavedNewsCard(
        news: news,
        onDelete: _reloadSavedNews,
      );
    }
  },
);

        },
      ),
    );
  }
}
