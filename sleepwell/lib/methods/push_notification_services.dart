import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class PushNotificationServices {
  static Future<void> getToken() async {
    final token = await FirebaseMessaging.instance.getToken();
    print("=======================================================");
    print(token);
    print("=======================================================");

    final serviceAccountsJson = {
      "type": "service_account",
      "project_id": "sleepwell-2d0c4",
      "private_key_id": "875f45b67b07a798a503f7eae5b6ed1b9c8adde8",
      "private_key":
          "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCzRhVnP0SpxO3r\nDbnrMY1OrBTbwU55NJErwL43hAJ7bZbU0Al5ukhRtdvna4MKbZtRyRjM99hgOVUl\ndkXzifyj+CT3j+rrrhaMpUMSmun1A9GJBajncLjpJzHAyoui0plKWsz8m6MzSJO4\nQ2WZmp/7yQJXPALDrOYfVYtwNIoztzdOdPsneXX3Ifi/UBoIe4GO+Hvkb2TC647E\nhaKpM2V+Osd+ObUIOl2qyA1Z+EIM9mvVSBhmuwvSdHGj453cUGrxf7iP5DphwNpC\nuxbQyeQofyw1K9xsKfOV19ynabOBGMPLjCJPLLv5p193LTQyTWJ2VCux7pgmVOet\nXhMyRPYxAgMBAAECggEADKYrpS/ugDSKDXlX1oeV5vjHFXzZlL1/5ziHq1rcAnm4\naF5f5sf9KY/FevoH4lTavk3sOy0bJinxby3d0Gnaarbb4+BSlOvBAU45Ue8ehhhN\ngOemc+MNFv1aGjZoXRYTNQ78UvAH1zreGmSd/vUtJ9q2WLGeJ9CToZ8bcjCw1iZv\nUvhe5tFrUktGjNMtKdf0f4UcOMVsAHoUI9osi9PiJ6XPGNhCkByqMAb9a2nNYcYk\nGY5xU9grFmtnTqNlVl317uk1k9q0patiZaWFc3CIcD6mWaD5zPIOpti0EoCpYd1R\nlZr11idA/wFujMHNG+BwPvIlvQvRJyl9Q7Gj3bQu6QKBgQDoPgYsltkXZJD//t2N\nSFBnT7EbjiF7XM48lV/NqvAog756CKiTLWv3RBK5MRxE0NVt4Kjlr4foyLOgJYVg\nNWO7irxuhERtebpUEzmvlNql7NSFgLBAhdnWqWptYIGWzBRRA0D+hqTSRU44dpWT\ncw+shXHN+2p0pMtl4u9w3w6pCQKBgQDFnOqhdliulhOO36Uod/E7AkjrhDLBZg4B\ny7NXqvQ0B2TPBmwQ0TkUWex6nuRt625KgMuwEQuZM/sdmZhLxMMM34UVfVs4iyd+\n0FYK6dyNKCA8BWyvmxydOtsDmcU4RNfbdH52ogdXM+YilWuIYMNzf9PUjqG/Cg71\n81J47Ex16QKBgQCRo2Onzqkw/EXZ42/4S2Lwho8gIo9olxhV8a50gT+9iHCIgqmE\nMjXEiBHdxKhflz5ge0QvVVY7arEKOr1bSd/TGft0qslmhbGNS8kfDI/ZAZ18Yukk\nbUvgS7mMAbsCX9RVwV6evrzZh9C3o9XE86DepYhqjcGCiF1s9VUGSTseUQKBgCPc\nXwPgCyXbnD8APOOEKKWxu3Pp8KACGiafRbNyFZDfip67Jp9CqJ4V14FFFmUQJVql\n1tDjtvwdX8O2XNnbIh5S7b7Bme0/63Hq8sJWQCzpjDf4MAoKFv49cQNNQ2n7rERp\n9o0myDg99dRu0y3TiYSLPPDE1Xtqot5lQqEpGJMJAoGAHwvZ+B847gLszPqd1pgZ\nDCn23CqO7y/u/IuyFNwNiTZM63sYYXTU+kTtCjokv9vrrmWo6+9CSAxqsXG+rpOz\nDWTKbsXty+YbWNWYgMxudb2vkWAcUFYoejL/H3lTlKr8WzSDAq6aomVh19CZwjtp\ncRCw38wOSkCAA2kLcUu+oLI=\n-----END PRIVATE KEY-----\n",
      "client_email":
          "flutter-uber-clone-taif-alrube@sleepwell-2d0c4.iam.gserviceaccount.com",
      "client_id": "106044012767656310371",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url":
          "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url":
          "https://www.googleapis.com/robot/v1/metadata/x509/flutter-uber-clone-taif-alrube%40sleepwell-2d0c4.iam.gserviceaccount.com",
      "universe_domain": "googleapis.com"
    };
    List<String> scopes = [
      "https://www.googleapis.com/auth/userinfo.email",
      "https://www.googleapis.com/auth/firebase.database",
      "https://www.googleapis.com/auth/firebase.messaging"
    ];
  }

  static sendNotificationToSelectorDriver(
      String deviceToken, BuildContext context, String title, String body) {}
}
