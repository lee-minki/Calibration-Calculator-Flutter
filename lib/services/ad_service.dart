import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  BannerAd? bannerAd;
  bool _isAdLoaded = false;
  bool _isAdFree = false;

  bool get isAdLoaded => _isAdLoaded && !_isAdFree;
  bool get isAdFree => _isAdFree;

  // Real Ad Unit ID
  static const String _bannerAdUnitId = 'ca-app-pub-6207233857071088/3219417982';
  
  // Test Ad Unit ID for development
  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _bannerAdUnitId;
      // Use test ID for development: 'ca-app-pub-3940256099942544/6300978111'
    }
    return _bannerAdUnitId;
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
