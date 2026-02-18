import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EventsPage extends StatelessWidget {
  const EventsPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 5, 115, 134),
          title: const Text("EVENTS"),
        ),
        body: Container(
            height: 1000,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
            child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    buildButton(context, "Spring Fest", 0, () {
                      _sf(context);
                    }),
                    buildButton(context, "Kshitij", 1, () {
                      _ktj(context);
                    }),
                    buildButton(context, "Shourya", 0, () {
                      _shourya(context);
                    }),
                    buildButton(context, "General Championship", 1, () {
                      _gc();
                    }),
                    buildButton(context, "Inter IIT", 0, () {
                      _interiit();
                    }),
                  ],
                ),
              ),
            ));
  }
}

Widget buildButton(
    BuildContext context, String text, int index, Function() onPressed) {
  Color buttonColor =
      index % 2 == 0 ? Colors.red : const Color.fromARGB(255, 40, 70, 94);

  return Padding(
    padding: const EdgeInsets.all(15.0),
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
          fontSize: 26.0,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    ),
  );
}

void _sf(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Spring Fest"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _sfweb();
                Navigator.of(context).pop();
              },
              child: const Text("Website"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _sffb();
                Navigator.of(context).pop();
              },
              child: const Text("Facebook"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _sfinsta();
                Navigator.of(context).pop();
              },
              child: const Text("Instagram"),
            ),
          ],
        ),
      );
    },
  );
}

void _ktj(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Kshitij"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _ktjweb();
                Navigator.of(context).pop();
              },
              child: const Text("Website"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _ktjyt();
                Navigator.of(context).pop();
              },
              child: const Text("YouTube"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _ktjinsta();
                Navigator.of(context).pop();
              },
              child: const Text("Instagram"),
            ),
          ],
        ),
      );
    },
  );
}

void _shourya(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Shourya"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                _shweb();
                Navigator.of(context).pop();
              },
              child: const Text("Website"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _shfb();
                Navigator.of(context).pop();
              },
              child: const Text("Facebook"),
            ),
            const SizedBox(height: 9),
            ElevatedButton(
              onPressed: () {
                _shinsta();
                Navigator.of(context).pop();
              },
              child: const Text("Instagram"),
            ),
          ],
        ),
      );
    },
  );
}

final Uri sf1 = Uri.parse('https://www.springfest.in/');
final Uri sf2 = Uri.parse('https://www.facebook.com/springfest.iitkgp/');
final Uri sf3 = Uri.parse('https://instagram.com/iitkgp.springfest/');
final Uri ktj1 = Uri.parse('https://ktj.in/');
final Uri ktj2 = Uri.parse('https://www.youtube.com/@ktj_iitkgp');
final Uri ktj3 = Uri.parse('https://www.instagram.com/ktj.iitkgp/');
final Uri sh1 = Uri.parse('https://shauryafest.in/');
final Uri sh2 = Uri.parse('https://www.facebook.com/shauryaiitkgp/');
final Uri sh3 = Uri.parse('https://www.instagram.com/shaurya.iitkgp/');
final Uri g = Uri.parse('https://gymkhana.iitkgp.ac.in/results/gc');
final Uri ii = Uri.parse('https://gymkhana.iitkgp.ac.in/results/interiit');

Future<void> _sfweb() async {
  if (!await launchUrl(sf1)) {
    throw Exception('Could not launch $sf1');
  }
}

Future<void> _sffb() async {
  if (!await launchUrl(sf2)) {
    throw Exception('Could not launch $sf2');
  }
}

Future<void> _sfinsta() async {
  if (!await launchUrl(sf3)) {
    throw Exception('Could not launch $sf3');
  }
}

Future<void> _ktjweb() async {
  if (!await launchUrl(ktj1)) {
    throw Exception('Could not launch $ktj1');
  }
}

Future<void> _ktjyt() async {
  if (!await launchUrl(ktj2)) {
    throw Exception('Could not launch $ktj2');
  }
}

Future<void> _ktjinsta() async {
  if (!await launchUrl(ktj3)) {
    throw Exception('Could not launch $ktj3');
  }
}

Future<void> _shweb() async {
  if (!await launchUrl(sh1)) {
    throw Exception('Could not launch $sh1');
  }
}

Future<void> _shfb() async {
  if (!await launchUrl(sh2)) {
    throw Exception('Could not launch $sh2');
  }
}

Future<void> _shinsta() async {
  if (!await launchUrl(sh3)) {
    throw Exception('Could not launch $sh3');
  }
}

Future<void> _gc() async {
  if (!await launchUrl(g)) {
    throw Exception('Could not launch $g');
  }
}

Future<void> _interiit() async {
  if (!await launchUrl(ii)) {
    throw Exception('Could not launch $ii');
  }
}
