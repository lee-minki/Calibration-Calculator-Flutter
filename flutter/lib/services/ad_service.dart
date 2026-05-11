import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFree = false;

  bool get isAdLoaded => _isAdLoaded && !_isAdFree;
  bool get isAdFree => _isAdFree;

  // Production AdMob unit (Android banner).
  static const String _prodBannerAndroid =
      'ca-app-pub-6207233857071088/3219417982';

  // Google-provided sample units. Used in debug/profile builds so we never
  // rack up real impressions during development (violates AdMob policy).
  // https://developers.google.com/admob/android/test-ads#sample_ad_units
  static const String _testBannerAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String _testBannerIos =
      'ca-app-pub-3940256099942544/2934735716';

  static String get bannerAdUnitId {
    if (kDebugMode || kProfileMode) {
      return Platform.isIOS ? _testBannerIos : _testBannerAndroid;
    }
    if (Platform.isAndroid) return _prodBannerAndroid;
    // iOS release needs its own production unit — fall back to test until set.
    return _testBannerIos;
  }

  Future<void> initialize() async {
    await MobileAds.instance.initialize();
    await _loadAdFreeStatus();
    if (!_isAdFree) {
      _loadBannerAd();
    }
  }

  Future<void> _loadAdFreeStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAdFree = prefs.getBool('ad_free') ?? false;
  }

  Future<void> setAdFree(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ad_free', value);
    _isAdFree = value;
    if (value) {
      bannerAd?.dispose();
      bannerAd = null;
      _isAdLoaded = false;
    } else {
      _loadBannerAd();
    }
  }

  void _loadBannerAd() {
    bannerAd = BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isAdLoaded = true;
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _isAdLoaded = false;
        },
      ),
    );
    bannerAd!.load();
  }

  void dispose() {
    bannerAd?.dispose();
  }
}
