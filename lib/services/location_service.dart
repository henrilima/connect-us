import 'package:connect/utils/messenger.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error("O serviço de localização está desativado.");
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> requestPermission(BuildContext context) async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever ||
          permission == LocationPermission.unableToDetermine) {
        if (!context.mounted) return;
        AppMessenger(
          context,
          "A permissão de localização foi recusada. Caso não seja possível aceitar novamente por aqui, vá as configurações do aplicativo e dê a permissão de localização.",
          "error",
        ).show();
        return;
      } else if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        if (!context.mounted) return;
        AppMessenger(
          context,
          "A permissão de localização foi aceita. Caso seu par já tenha permitido, essa tela atualizará na próxima vez que você abrir o app.",
          "success",
        ).show();
        return;
      }
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      if (!context.mounted) return;
      AppMessenger(
        context,
        "A permissão de localização já havia sido aceita. Esta tela atualizará na próxima vez que você abrir o app e seu par permitir acesso a localização dele.",
        "success",
      ).show();
      return;
    }
  }

  Future<bool> hasPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever ||
        permission == LocationPermission.unableToDetermine) {
      return false;
    } else if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      return true;
    } else {
      return false;
    }
  }
}
