// import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../../constants.dart';

class SignUpScreenTopImage extends StatelessWidget {
  const SignUpScreenTopImage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "Sign Up".toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: defaultPadding),
        const Row(
          children: [
            Spacer(),
            // Expanded(
            //   flex: 8,
            //   child: SvgPicture.asset("assets/icons/signup.png"),
            // ),
            Spacer(),
          ],
        ),
        const SizedBox(height: defaultPadding),
      ],
    );
  }
}
