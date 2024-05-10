// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';
// import '../../../constants.dart';

class WelcomeImage extends StatelessWidget {
  const WelcomeImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 175,
          width: 175,
          child: Image.asset(
            'assets/images/logo.png',
            width: 150,
            fit: BoxFit.fitHeight,
          ),
        ),
        const SizedBox(height: 60),
        const SizedBox(
          height: 60,
          child: Text(
            "IIT KGP STUDENT APP",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
          ),
        ),
        const SizedBox(height: 25),
      ],
    );
  }
}
