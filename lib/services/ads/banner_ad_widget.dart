// lib/widgets/ads/banner_ad_widget.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:walleta/services/ads/ads_manager.dart';

class BannerAdWidget extends StatefulWidget {
  final bool isPremium;
  final AdSize? adSize;

  const BannerAdWidget({
    Key? key,
    required this.isPremium,
    this.adSize = AdSize.banner,
  }) : super(key: key);

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (!widget.isPremium) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd = BannerAd(
      size: widget.adSize ?? AdSize.banner,
      adUnitId: AdsManager.bannerAdUnitId,
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          print('✅ Banner ad loaded');
        },
        onAdFailedToLoad: (ad, error) {
          print('❌ Banner ad failed to load: $error');
          ad.dispose();
        },
      ),
      request: const AdRequest(),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No mostrar anuncios a usuarios premium
    if (widget.isPremium) {
      return const SizedBox.shrink();
    }

    // Si el anuncio no se ha cargado, mostrar placeholder
    if (!_isAdLoaded || _bannerAd == null) {
      return Container(
        height: widget.adSize?.height.toDouble() ?? 50,
        color: Colors.grey[200],
        child: Center(
          child: Text(
            'Cargando anuncio...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
