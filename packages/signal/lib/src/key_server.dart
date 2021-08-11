import 'dart:convert';

import 'package:http/http.dart' as http;

class KeyServer {
  static const SERVER_URL = 'http://localhost:3000/';

  Future<KeyObject> fetchKey(String name) async {
    final response = await http.get(Uri.parse(SERVER_URL + name));

    if (response.statusCode == 200) {
      return KeyObject.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Key');
    }
  }

  Future<void> storeKey(KeyObject ko) async {
    final response = await http.post(Uri.parse(SERVER_URL + ko.username));

    if (response == 200) {
      return;
    } else {
      throw Exception('Something dumb happened');
    }
  }
}

class KeyObject {
  final String username;
  final String identityKeyPair;
  final String deviceId;
  final String preKeyId;
  final String signedPreKeyId;
  final String preKey;
  final String registrationId;

  KeyObject({
    required this.username,
    required this.identityKeyPair,
    required this.deviceId,
    required this.preKeyId,
    required this.signedPreKeyId,
    required this.preKey,
    required this.registrationId,
  });

  factory KeyObject.fromJson(Map<String, dynamic> json) {
    return KeyObject(
      username: json['username'],
      identityKeyPair: json['identityKeyPair'],
      deviceId: json['deviceId'],
      preKeyId: json['preKeyId'],
      signedPreKeyId: json['signedPreKeyId'],
      preKey: json['preKey'],
      registrationId: json['registrationId'],
    );
  }
}
