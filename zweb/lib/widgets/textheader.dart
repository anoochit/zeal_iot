import 'package:flutter/material.dart';
import 'package:zweb/const.dart';

class TextHeader extends StatelessWidget {
  const TextHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Text(title, style: kTextHeaderPage),
    );
  }
}
