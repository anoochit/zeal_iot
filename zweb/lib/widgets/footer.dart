import 'package:flutter/material.dart';
import 'package:zweb/utils/utils.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          const Text("Made with "),
          const Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          const Text(" by "),
          InkWell(
            child: const Text("RedLine Software"),
            onTap: () => launchURL("http://redlinesoft.net"),
          )
        ],
      ),
    );
  }
}
