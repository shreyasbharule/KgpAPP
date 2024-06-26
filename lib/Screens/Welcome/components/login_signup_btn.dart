// import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:path_provider/path_provider.dart';

// import '../../../constants.dart';
import '../../Login/login_screen.dart';
// import '../../Signup/signup_screen.dart';

class LoginAndSignupBtn extends StatelessWidget {
  const LoginAndSignupBtn({
    super.key,
  });

  void rolldice() {}

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Hero(
          tag: "login_btn",
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginScreen();
                  },
                ),
              );
            },
            child: Text(
              "Login".toUpperCase(),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // ElevatedButton(
        //   onPressed: () {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (context) {
        //           return const SignUpScreen();
        //         },
        //       ),
        //     );
        //   },
        // style: ElevatedButton.styleFrom(
        //     backgroundColor: kPrimaryLightColor, elevation: 0),
        // child: Text(
        //   "Sign Up".toUpperCase(),
        //   style: const TextStyle(color: Colors.black),
        // ),
        // ),
        const SizedBox(height: 50),
        const SizedBox(height: 40),
      ],
    );
  }
}
