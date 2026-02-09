// lib/services/interstitial_ad_manager.dart - VERSIÓN MEJORADA
import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:walleta/services/ads/ads_manager.dart';

class InterstitialAdManager {
  static InterstitialAd? _interstitialAd;
  static bool _isLoading = false;
  static bool _isAdReady = false;
  static Completer<void>? _adCompleter;

  // Cargar anuncio intersticial
  static Future<void> loadInterstitial() async {
    if (_isLoading || _isAdReady) return;

    _isLoading = true;
    print('🔄 Cargando interstitial ad...');

    try {
      await InterstitialAd.load(
        adUnitId: AdsManager.interstitialAdUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd = ad;
            _isLoading = false;
            _isAdReady = true;
            print('✅ Interstitial ad cargado y listo');

            ad.fullScreenContentCallback = FullScreenContentCallback(
              onAdDismissedFullScreenContent: (ad) {
                print('👋 Interstitial ad cerrado');
                ad.dispose();
                _interstitialAd = null;
                _isAdReady = false;
                // Recargar otro anuncio
                Future.delayed(const Duration(seconds: 1), () {
                  loadInterstitial();
                });
              },
              onAdFailedToShowFullScreenContent: (ad, error) {
                print('❌ Error al mostrar interstitial: $error');
                ad.dispose();
                _interstitialAd = null;
                _isAdReady = false;
                loadInterstitial();

                // Completar el completer si existe
                if (_adCompleter != null && !_adCompleter!.isCompleted) {
                  _adCompleter!.completeError(error);
                }
              },
              onAdShowedFullScreenContent: (ad) {
                print('🎬 Interstitial ad mostrado');
              },
              onAdImpression: (ad) {
                print('👁️ Interstitial ad impression');
              },
            );

            // Completar el completer si existe
            if (_adCompleter != null && !_adCompleter!.isCompleted) {
              _adCompleter!.complete();
            }
          },
          onAdFailedToLoad: (error) {
            print('❌ Error al cargar interstitial: $error');
            print('📋 Error details: ${error.message}');
            _isLoading = false;
            _isAdReady = false;

            // Completar el completer con error
            if (_adCompleter != null && !_adCompleter!.isCompleted) {
              _adCompleter!.completeError(error);
            }

            // Reintentar después de 30 segundos
            Future.delayed(const Duration(seconds: 30), () {
              loadInterstitial();
            });
          },
        ),
      );
    } catch (e) {
      print('💥 Excepción en loadInterstitial: $e');
      _isLoading = false;
      _isAdReady = false;
    }
  }

  // Mostrar anuncio intersticial con mejor manejo
  static Future<void> showInterstitial() async {
    print('🎯 Intentando mostrar interstitial...');
    print('📊 Estado: isAdReady=$_isAdReady, isLoading=$_isLoading');

    if (!_isAdReady || _interstitialAd == null) {
      print('⚠️ No hay anuncio disponible, cargando uno nuevo...');

      // Crear un completer para esperar la carga
      _adCompleter = Completer<void>();

      // Cargar anuncio
      await loadInterstitial();

      try {
        // Esperar máximo 5 segundos a que cargue
        await _adCompleter!.future.timeout(const Duration(seconds: 5));
        print('✅ Anuncio cargado exitosamente, mostrando...');
      } catch (e) {
        print('⏰ Timeout o error esperando anuncio: $e');
        return; // Salir si no se pudo cargar
      }
    }

    if (_interstitialAd != null && _isAdReady) {
      try {
        await _interstitialAd!.show();
        print('🎬 Interstitial ad mostrado exitosamente');
      } catch (e) {
        print('❌ Error al ejecutar show(): $e');
        // Recargar si falla
        _isAdReady = false;
        loadInterstitial();
      }
    } else {
      print('🚫 No se pudo mostrar el anuncio');
    }
  }

  // Verificar si hay anuncio disponible
  static bool get isAdReady => _isAdReady;
}
