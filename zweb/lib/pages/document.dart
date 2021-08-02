import 'package:flutter/material.dart';
import 'package:zweb/contents/document.dart';
import 'package:zweb/widgets/main_menu.dart';

class DocumentPage extends StatefulWidget {
  DocumentPage({Key? key}) : super(key: key);

  @override
  _DocumentPageState createState() => _DocumentPageState();
}

class _DocumentPageState extends State<DocumentPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: MainMenu(),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            DocumentContent(),
          ],
        ),
      ),
    );
  }
}
