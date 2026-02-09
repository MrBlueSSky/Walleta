// lib/services/rewarded_ad_manager.dart
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:walleta/services/ads/ads_manager.dart';

class RewardedAdManager {
  static RewardedAd? _rewardedAd;
  static bool _isLoading = false;

  // Para usuarios no premium que quieren beneficios extra
  static Future<void> loadRewarded() async {
    if (_isLoading || _rewardedAd != null) return;

    _isLoading = true;

    await RewardedAd.load(
      adUnitId: AdsManager.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isLoading = false;
          print('✅ Rewarded ad loaded');
        },
        onAdFailedToLoad: (error) {
          print('❌ Failed to load rewarded ad: $error');
          _isLoading = false;
        },
      ),
    );
  }

  // Mostrar anuncio con recompensa
  static Future<void> showRewarded({
    required Function(RewardItem) onReward,
    required Function() onAdDismissed,
  }) async {
    if (_rewardedAd == null) {
      print('⚠️ No rewarded ad available');
      return;
    }

    _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        onAdDismissed();
        loadRewarded(); // Cargar próximo
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        print('❌ Failed to show rewarded ad: $error');
        ad.dispose();
        _rewardedAd = null;
        loadRewarded();
      },
    );

    // Configurar recompensa
    _rewardedAd!.setImmersiveMode(true);
    _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        print('🎁 Reward earned: ${reward.amount} ${reward.type}');
        onReward(reward);
      },
    );
  }

  // Ofrecer recompensa por ver anuncio
  static void offerPremiumTrial(BuildContext context, bool isPremium) {
    if (isPremium) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ya eres usuario premium!')));
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('🎁 Obtén 1 día premium gratis'),
            content: Text(
              'Mira un anuncio completo y disfruta de 24 horas sin anuncios y con todas las funciones premium.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showRewardForPremiumTrial(context);
                },
                child: Text('Ver anuncio'),
              ),
            ],
          ),
    );
  }

  static Future<void> _showRewardForPremiumTrial(BuildContext context) async {
    await showRewarded(
      onReward: (reward) {
        // Aquí darías 1 día de premium gratis
        // Por ejemplo: context.read<AuthenticationBloc>().add(AddPremiumDays(1));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 ¡Felicidades! Tienes 1 día premium gratis'),
            backgroundColor: Colors.green,
          ),
        );
      },
      onAdDismissed: () {
        print('Rewarded ad dismissed');
      },
    );
  }
}
