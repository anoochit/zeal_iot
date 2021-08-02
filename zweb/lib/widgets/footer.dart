import 'package:flutter/material.dart';
import 'package:zweb/utils/utils.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        children: [
          Text("Made with "),
          Icon(
            Icons.favorite,
            color: Colors.red,
          ),
          Text(" by "),
          InkWell(
            child: Text("RedLine Software"),
            onTap: () => launchURL("http://redlinesoft.net"),
          )
        ],
      ),
    );
  }
}
