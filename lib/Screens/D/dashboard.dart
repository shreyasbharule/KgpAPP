import 'package:flutter/material.dart';
import 'package:login_app_page/Screens/Login/login_screen.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:login_app_page/Screens/D/maps.dart';
import 'package:login_app_page/Screens/D/academic_calendar.dart';
import 'package:login_app_page/Screens/D/events.dart';

final Uri lib = Uri.parse('https://library.iitkgp.ac.in/');
final Uri erp = Uri.parse('https://erp.iitkgp.ac.in/');

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 36, 82, 90),
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LoginScreen(),
              ),
            );
          },
        ),
        backgroundColor: const Color.fromARGB(255, 5, 115, 134),
        title: const Text(
          'KGP STUDENT APP',
        ),
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
                const SizedBox(
                  height: 170,
                ),
                buildButton(context, 'Academic Calendar', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AcademicCalendarPage(),
                    ),
                  );
                }),
                buildButton(context, 'Events', () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EventsPage(),
                    ),
                  );
                }, backgroundColor: const Color.fromARGB(255, 40, 70, 94)),
                buildButton(context, 'ERP', _launchERP),
                buildButton(context, 'Library Resources', _launchLib,
                    backgroundColor: const Color.fromARGB(255, 40, 70, 94)),
                buildButton(
                  context,
                  'Maps',
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MapsPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButton(BuildContext context, String text, Function() onPressed,
      {Color backgroundColor = Colors.blue}) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: backgroundColor,
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

  Future<void> _launchERP() async {
    if (!await launchUrl(erp)) {
      throw Exception('Could not launch $erp');
    }
  }

  Future<void> _launchLib() async {
    if (!await launchUrl(lib)) {
      throw Exception('Could not launch $lib');
    }
  }
}
