import 'dart:ui';

import 'package:google_mobile_ads/google_mobile_ads.dart';

class Interstitialadwidget {
  static InterstitialAd? _interstitialAd;

  static void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: 'ca-app-pub-6846718920811344/3147707437',
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (error) {
          print('InterstitialAd failed to load: $error');
        },
      ),
    );
  }

  static void showInterstitialAd() {
  if (_interstitialAd != null) {
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _interstitialAd!.dispose();
        _interstitialAd = null;
        loadInterstitialAd(); // Load the next ad
       // onAdClosed(); // Trigger navigation as soon as the ad is closed
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _interstitialAd!.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
       // onAdClosed(); // Trigger navigation even if the ad fails to show
      },
    );

    _interstitialAd!.show();
  } else {
    // If the ad isn't ready, proceed to the next page immediately
    print("Interstitial ad is not ready yet.");
    //onAdClosed();
  }
}

}
