import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';


class Temp extends StatefulWidget {
  const Temp({super.key});

  @override
  State<Temp> createState() => _TempState();
}

class _TempState extends State<Temp> {

NativeAd? nativeAd;
RxBool isLoaded = false.obs;
final String adunitId= "ca-app-pub-3940256099942544/2247696110";

loadAd(){
  nativeAd = NativeAd(
    adUnitId: adunitId,
    listener: NativeAdListener(
      onAdLoaded: (ad){
        isLoaded.value= true;
      },
      onAdFailedToLoad: (ad,error){
        isLoaded.value=false;
      }
  ),
   request: AdRequest(),
   nativeTemplateStyle: NativeTemplateStyle(templateType: TemplateType.small)
  
  );

  nativeAd!.load();
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [

            AdWidget(ad: loadAd()),
        ],
      ),
    );
  }
}