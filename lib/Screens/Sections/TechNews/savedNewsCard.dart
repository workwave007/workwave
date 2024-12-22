import 'dart:convert';

import 'package:easy_url_launcher/easy_url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:job_apply_hub/Screens/Sections/TechNews/techNewsSection.dart';
import 'package:shared_preferences/shared_preferences.dart';
class SavedNewsCard extends StatelessWidget {
  final News news;
  final Function onDelete;

  const SavedNewsCard({super.key, required this.news,required this.onDelete});

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
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () async{
                     await SavedNewsManager.deleteNews(news);
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('News removed from bookmarks')),
);
onDelete();
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
