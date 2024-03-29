import 'package:flutter/material.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void setAuthToken(String token) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: 'authToken', value: token);
}

Future<String> getAuthToken() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'authToken');
  return token;
}

void setSpotifyAccessToken(String token) async {
  final storage = FlutterSecureStorage();
  await storage.write(key: 'spotifyAccessToken', value: token);
}

Future<String> getSpotifyAccessToken() async {
  final storage = FlutterSecureStorage();
  final token = await storage.read(key: 'spotifyAccessToken');
  return token;
}

void logout(BuildContext context) async {
  final storage = FlutterSecureStorage();
  await storage.deleteAll();
  Navigator.of(context)
      .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
}
