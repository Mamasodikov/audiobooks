import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:audiobooks/core/helper/custom_toast.dart';

class AboutPage extends StatefulWidget {
  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  // Function to launch a URL
  Future<void> _launchUrl(Uri uri) async {
    try {
      await launchUrl(uri);
    } catch (e) {
      print(e);
      CustomToast.showToast('This action is not supported');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("About Developer"),
        iconTheme: IconThemeData(color: Colors.white), // Adjust if needed
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '👨‍💻',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 100),
              ),
              SizedBox(height: 20),
              Text(
                'Hi 👋, I am Muhammad Aziz. This app is open sourced for educational purposes, so you can get use of it :)\n App might be little buggy, cuz it was done in just 2 days for test assignment, feel free to open an issue in repo 🫡\n\n',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black, // Use cBlackColor if defined
                ),
              ),
              _buildLinkText(
                'Website: ',
                'www.flutterdev.uz',
                'https://www.flutterdev.uz',
              ),
              _buildLinkText(
                'Email: ',
                'generalmarshallinbox@gmail.com',
                'mailto:generalmarshallinbox@gmail.com',
              ),
              _buildLinkText(
                'Phone: ',
                '+998911283725',
                'tel:+998911283725',
              ),
              _buildLinkText(
                'Telegram: ',
                't.me/mamasodikoff',
                'https://t.me/mamasodikoff',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLinkText(String label, String linkText, String url) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: GestureDetector(
        onTap: () => _launchUrl(Uri.parse(url)),
        child: RichText(
          text: TextSpan(
            text: '$label',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black, // Use cBlackColor if defined
            ),
            children: [
              TextSpan(
                text: linkText,
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
