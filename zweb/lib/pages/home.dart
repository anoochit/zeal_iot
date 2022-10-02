import 'package:flutter/material.dart';
import 'package:zweb/contents/home.dart';
import 'package:zweb/widgets/footer.dart';
import 'package:zweb/widgets/main_menu.dart';

class HomePage extends StatefulWidget {
  HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: MainMenu(),
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HomeContent(),
              // footer
              SizedBox(height: 32.0),
              Footer(),
              SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }
}
