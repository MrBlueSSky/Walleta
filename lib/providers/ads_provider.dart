// lib/providers/ads_provider.dart - VERSIÓN MEJORADA
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:walleta/blocs/authentication/bloc/authentication_bloc.dart';
import 'package:walleta/services/ads/interstitial_ad_manager.dart';

class AdsProvider with ChangeNotifier {
  bool _isPremium = false;
  StreamSubscription? _authSubscription;

  AdsProvider();

  void initialize(BuildContext context) {
    _listenToAuthChanges(context);
  }

  void _listenToAuthChanges(BuildContext context) {
    _authSubscription?.cancel();

    final authBloc = context.read<AuthenticationBloc>();

    _authSubscription = authBloc.stream.listen((authState) {
      if (authState.status == AuthenticationStatus.authenticated) {
        final newPremiumStatus = authState.user.isPremium;

        if (newPremiumStatus != _isPremium) {
          _isPremium = newPremiumStatus;
          print('🔄 AdsProvider: Premium actualizado a $_isPremium');
          notifyListeners();
        }
      }
    });
  }

  void updatePremiumStatus(bool isPremium) {
    if (_isPremium != isPremium) {
      _isPremium = isPremium;
      print('🔄 AdsProvider: Premium actualizado manualmente a $isPremium');
      notifyListeners();
    }
  }

  Future<void> showAdOnButtonTap({
    required BuildContext context,
    required VoidCallback onAfterAd,
    VoidCallback? onAdFailed,
    bool forceShow = true,
  }) async {
    print('🎯 showAdOnButtonTap llamado');
    print('👤 Estado premium: $_isPremium');

    // Si es premium, no mostrar anuncios
    if (_isPremium) {
      print('👑 Usuario premium - Saltando anuncio');
      onAfterAd();
      return;
    }

    print('🔄 Preparando para mostrar anuncio...');

    try {
      // Mostrar el anuncio
      await InterstitialAdManager.showInterstitial();
      print('✅ Anuncio mostrado exitosamente');

      // Ejecutar la acción después del anuncio
      onAfterAd();
    } catch (e) {
      print('❌ Error al mostrar anuncio: $e');

      // Mostrar snackbar de error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('No se pudo cargar el anuncio'),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 2),
        ),
      );

      // Ejecutar acción de todas formas
      onAfterAd();

      if (onAdFailed != null) onAdFailed();
    }
  }

  bool get isPremium => _isPremium;
  bool get shouldShowAds => !_isPremium;

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void printStatus() {
    print('📊 AdsProvider - Premium: $_isPremium');
  }
}
