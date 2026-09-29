import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> launchURL(String url, BuildContext context) async {
  try {
    await launchUrl((Uri.parse(url)), mode: LaunchMode.externalApplication);
  } catch (e) {
    if (!context.mounted) return;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text("Could not launch $url"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
