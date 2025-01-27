import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart' as auth;

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static void initialize() {
    const InitializationSettings settings = InitializationSettings(
      android: AndroidInitializationSettings("@mipmap/ic_launcher"),
    );

    _notificationsPlugin.initialize(settings);
  }

  void showNotification(RemoteMessage message) async {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      "channel_id",
      "channel_name",
      importance: Importance.max,
      priority: Priority.high,
    );

    NotificationDetails details = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      message.notification!.title!,
      message.notification!.body!,
      details,
    );
  }


  Future<String> getAccessToken() async {
    final serviceAccountJson = {
      "type": "service_account",
      "project_id": "uninote-b65b3",
      "private_key_id": "5289af135983ec63efc49866a3c6e679fbf0a273",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzVE0TT8Ishz3n\nmVMWgIzfr+TEpOy24QlCmnbPNxK17nE7d/LBJy+Pb1uh9zwWhl7xbiXEfY5LhEEW\nOVjW0HEM2MfCjBkDrs152gLtH+2k53om0lDfPIVwO17TAyCtq4ksiwUemeeeqilg\n8nA+cSGj1T25xVqxiKKHLNKbVh9SHjr3aiHuNKjPQS26PvcT2kWu0pU3fFgIXmDT\nWRmwqCVU2UBBEKaP+hdhD3fISYi0MssXR5yS/xJMAWnlYXF7PqFBFnuSLq5+cMnl\nJK3V28DtUFmAQP0SOi6VK16h4ETBKnpuvoVR+nfeY6Q2XvUeEZkMa5Use0LHYNA4\nhYF+0JnlAgMBAAECggEAICw86rzJt57o3IrttPEJtRzztFLpdBLyDBy1uY3mIbU+\nY96scvpShk+Cd0+pnFntoS9zf6nN9F7tJW1S8rExQw6GYjEr0LUVAKo8EapDgq0T\nxXDAmRhc0UqZg86BF59ZjCAB4mBWxWi+ZToBqLY3xJKekRxm3ciHbix8uWktU9gy\n6BpVBrGP4VPmPZL/WcaoTVE+fCCjhRZXY/Bfi2wLQbv62roUeQYKog7mGDY/od5Y\nKDq1A0reGJyyuRl1EcEhbhBASJxfUSyfiqkDx3dlK99COyChIk3UO8dCefmp/IDm\n3W1ZUi3qV/3FO6+aWdKTePqqvmUONzre+NtB5JVd2QKBgQDqUpOaXaMV0yvfzkPR\nzwN9j4jMVaN81x2DBKFgPUA+g3CS6AwdkvXsyEJ4x8m06HJG3ezAJQMiQOF06inW\n+lZnYl2qFgKcgEr5K1ONN1oZxWffpKhdXLP7TLSBuak3YdYhGlipl+xyw7L6bQ0C\n+BW9mp6Ilay8d+deAmbrub6OzQKBgQDD61PzCl6fwF7XPQqtPW+gJzkytOTxQRie\nqPlet4EI1maOy77wcJ0UTgKf8zdBnDu09KBZbuKGlOAZyClM7t3eeWGxKSjgbmYp\nDV570hlTQlpQL98ChtaqpodZrqv2Z18eVZifLmX+I5ONrxvv/pZfc8d+A3aTf6O5\ngzqCPjWHeQKBgB+e/SQ7tqJfWPBe2XAay5HKKN/KPsG+FdF0coKWQXEuM6bfgaMM\nDfviGnZKH8I2DBXcJPLZC883ijVI1FSae8Z/07v8NGYCOhvd6OyJp7MKnLXldoMC\n25byBvnqoBdFMKxO7eAVDGeAWUrKJJNd/zETCInOCP12ANcC4/iznC+RAoGBAK7d\nVbpxIO+5BW1a4DKryPvKxnSJnGXwUgcajiiJ5LN8mWEOXUfBW5IJ5rHYpRL8XRYv\n2Qa5v5mbO0IHs0UlVgYBlL5JHGDkaG5vrksZxNzZNj6n24Ynz2XU6K2VB4sPzIgI\nogZBpWrlWgd1qZvVQWXEsuO4N5eCryEfDZO97o0RAoGAahQopw8yDE6ngBmvtA2s\nfz2s1jtLbcTmCvz7BoASiwDZSuYLMnYNqmbs7L8j85mveeRhsdXkLgwicIYd/Yf/\neZoFCh0ISy6z2zStn/ywysNkaQp5YyuSjyKvw1501OOa8PIuGxgTEQV5wGD6x/yz\nk9/JpJnR5HYrwr4J26vMvgI=\n-----END PRIVATE KEY-----\n",
      "client_email": "firebase-adminsdk-s7i3g@uninote-b65b3.iam.gserviceaccount.com",
      "client_id": "115947055530372110532",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
    };

    List<String> scopes = [
      "https://www.googleapis.com/auth/firebase.messaging"
    ];

    var client = await auth.clientViaServiceAccount(
      auth.ServiceAccountCredentials.fromJson(serviceAccountJson),
      scopes,
    );

    return client.credentials.accessToken.data;
  }

  Future<void> sendNotification(String title, String body) async {
    String accessToken = await getAccessToken();
    String? deviceToken = await _messaging.getToken();

    if (deviceToken == null) return;

    final message = {
      "message": {
        "token": deviceToken,
        "notification": {"title": title, "body": body},
      }
    };

    await http.post(
      Uri.parse("https://fcm.googleapis.com/v1/projects/uninote-b65b3/messages:send"),
      headers: {"Content-Type": "application/json", "Authorization": "Bearer $accessToken"},
      body: jsonEncode(message),
    );
  }

  void listenNotifications() {
    FirebaseMessaging.onMessage.listen((message) {
      showNotification(message);
    });
  }
}
