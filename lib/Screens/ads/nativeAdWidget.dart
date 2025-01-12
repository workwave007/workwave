import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class NativeAdWidget extends StatefulWidget {
  @override
  _NativeAdWidgetState createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  late NativeAd nativeAd;
  bool areAdsLoaded = false;

  @override
  void initState() {
    super.initState();
    nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-6846718920811344/7395723021', // Replace with your ad unit ID
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.medium),
      listener: NativeAdListener(
        onAdLoaded: (ad) {
          setState(() {
            areAdsLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          setState(() {
            areAdsLoaded = false;
          });
          debugPrint('Failed to load native ad: $error');
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    nativeAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 350,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: areAdsLoaded
            ? NativeAdWidgetFromAd(nativeAd: nativeAd)
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(child: Text("Failed to Load ads")),
                ),
              ),
      ),
    );
  }
}

class NativeAdWidgetFromAd extends StatelessWidget {
  final NativeAd nativeAd;

  const NativeAdWidgetFromAd({required this.nativeAd});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: AdWidget(ad: nativeAd),
    );
  }
}