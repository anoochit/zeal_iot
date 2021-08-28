import 'package:flutter/material.dart';

class TextSubHeader extends StatelessWidget {
  const TextSubHeader({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(left: 24),
      child: Text(title),
    );
  }
}
