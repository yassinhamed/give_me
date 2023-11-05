import 'dart:convert';
import 'dart:io';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:markets_deliveryboy/src/repository/settings_repository.dart';

import '../helpers/custom_trace.dart';
import '../helpers/helper.dart';
import '../models/notification.dart';
import '../models/user.dart';
import '../repository/user_repository.dart' as userRepo;

Future<Stream<Notification>> getNotifications() async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Stream.value(new Notification());
  }
  final String _apiToken = 'api_token=${_user.apiToken}&';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}notifications?${_apiToken}search=notifiable_id:${_user.id}&searchFields=notifiable_id:=&orderBy=created_at&sortedBy=desc&limit=10';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Notification.fromJSON(data);
  });
}

Future<Notification> markAsReadNotifications(Notification notification) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Notification();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}notifications/${notification.id}?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.put(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
    body: json.encode(notification.markReadMap()),
  );
  print(
      "[${response.statusCode}] NotificationRepository markAsReadNotifications");
  return Notification.fromJSON(json.decode(response.body)['data']);
}

Future<Notification> removeNotification(Notification cart) async {
  User _user = userRepo.currentUser.value;
  if (_user.apiToken == null) {
    return new Notification();
  }
  final String _apiToken = 'api_token=${_user.apiToken}';
  final String url =
      '${GlobalConfiguration().getValue('api_base_url')}notifications/${cart.id}?$_apiToken';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.delete(
    uri,
    headers: {HttpHeaders.contentTypeHeader: 'application/json'},
  );
  print("[${response.statusCode}] NotificationRepository removeCart");
  return Notification.fromJSON(json.decode(response.body)['data']);
}

/*
Future<void> sendNotification(String body, String title, User user) async {
  final data = {
    "notification": {"body": "$body", "title": "$title"},
    "priority": "high",
    "data": {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "messages",
      "status": "done"
    },
    "to": "${user.deviceToken}"
  };
  final String url = 'https://fcm.googleapis.com/fcm/send';
  final client = new http.Client();
  Uri uri = Uri.parse(url);
  final response = await client.post(
    uri,
    headers: {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: "key=${setting.value.fcmKey}",
    },
    body: json.encode(data),
  );
  if (response.statusCode != 200) {
    print('notification sending failed');
  }
}
*/
Future<void> sendNotification(
    {String deviceToken, String title, String body, String type}) async {
  final String url = 'https://fcm.googleapis.com/fcm/send';
  String server_key =
      'AAAAzoceVJQ:APA91bFlQ8KANU9QwTJc3gPCF8WDcyO90wsORAFfpdsC8v4RWFSGj3y8wpL2Z0vTfZnQfgoKHM-qDme0IlyVP68L8V2YCTThUr7sr9PeXm_FkoluTCsSkuuJxuzOyBhHD2Lv2D5F32eE';
  Map<String, String> _headers = {
    HttpHeaders.contentTypeHeader: 'application/json',
    HttpHeaders.authorizationHeader: 'key=$server_key'
  };
  Map<String, dynamic> _body = {
    'to': deviceToken,
    'notification': {
      'title': title,
      'body': body,
      'sound': 'notification_sound.mp3',
    },
    'android': {
      'priority': 'HIGH',
      'notification': {
        'notification_priority': 'PRIORITY-MAX',
        'sound': 'notification_sound.mp3',
        'default_sound': true,
        'default_vibrate_timings': true,
        'default_light-settings': true,
      },
    },
    'data': {
      'type': type,
      'id': '87',
      'click_action': 'FLUTTER_NOTIFICATION_CLICK'
    },
  };
  try {
    final client = http.Client();
    Uri uri = Uri.parse(url);
    var response =
    await client.post(uri, headers: _headers, body: json.encode(_body));
    print('status code: ${response.statusCode}');
    print('response: ${response.body}');
  }catch(e){
    print('error when send notification: $e');
  }

}

