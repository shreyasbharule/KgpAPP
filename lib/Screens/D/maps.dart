import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

final Uri bcroy = Uri.parse(
    'https://www.google.com/maps/dir/22.3228254,87.3096798/B+C+Roy+Technology+Hospital,+Indian+Institute+of+Technology+Kharagpur,+Scholars+Avenue,+Campus,+Kharagpur,+West+Bengal+721302/@22.318356,87.2916265,15z/data=!3m1!4b1!4m9!4m8!1m1!4e1!1m5!1m1!1s0x3a1d43ff3825e86b:0xb83b6fe7ab515e3c!2m2!1d87.3002416!2d22.3168542?entry=ttu');
final Uri police = Uri.parse(
    'https://www.google.com/maps/dir/22.3228254,87.3096798/Police+Station,+IIT+Kharagpur,+Kharagpur,+West+Bengal/@22.3212753,87.3030978,16z/data=!4m10!4m9!1m1!4e1!1m5!1m1!1s0x3a1d440446c624a1:0x70c530139273b34c!2m2!1d87.3080454!2d22.3194375!3e0?entry=ttu');
final Uri mb = Uri.parse(
    'https://www.google.com/maps/place/Main+Building,+IIT+Kharagpur,+Kharagpur,+West+Bengal+721302/@22.3197333,87.3074296,17z/data=!3m1!4b1!4m6!3m5!1s0x3a1d4404e9413a63:0x443d820a3a447f82!8m2!3d22.3197284!4d87.3100045!16s%2Fg%2F1hhhvf5lr?entry=ttu');

class MapsPage extends StatelessWidget {
  const MapsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 5, 115, 134),
        title: const Text('MAPS'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.white.withOpacity(0.6),
                BlendMode.lighten,
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
                width: MediaQuery.of(context).size.width * 0.4,
                height: MediaQuery.of(context).size.height * 0.2,
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildButton(context, 'BC Roy Hospital', 0, () {
                  _showBCRoyDetails(context);
                }),
                buildButton(context, 'Main Building', 1, () {
                  _launchMap2();
                }),
                buildButton(context, 'Police Station', 0, () {
                  _launchMap3();
                }),
                buildButton(context, 'View Doctor Availability', 1, () {
                  _viewPDF(context);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(
      BuildContext context, String text, int index, Function() onPressed) {
    Color buttonColor =
        index % 2 == 0 ? Colors.red : const Color.fromARGB(255, 40, 70, 94);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: buttonColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Future<void> _launchMap1() async {
    if (!await launchUrl(bcroy)) {
      throw Exception('Could not launch $bcroy');
    }
  }

  Future<void> _launchMap2() async {
    if (!await launchUrl(mb)) {
      throw Exception('Could not launch $mb');
    }
  }

  Future<void> _launchMap3() async {
    if (!await launchUrl(police)) {
      throw Exception('Could not launch $police');
    }
  }

  void _viewPDF(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'BC Roy Hospital Doctor Availibilty',
              style: TextStyle(fontSize: 20),
            ),
          ),
          body: SfPdfViewer.asset('assets/pdfs/bcroy.pdf'),
        );
      },
    );
  }

  void _showBCRoyDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('BC Roy Hospital'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Contact: 03222 255 221'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _launchMap1();
                  Navigator.of(context).pop();
                },
                child: const Text('View Map'),
              ),
            ],
          ),
        );
      },
    );
  }
}
