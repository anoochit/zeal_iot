import 'package:flutter/material.dart';
import 'package:zweb/contents/home.dart';
import 'package:zweb/widgets/footer.dart';
import 'package:zweb/widgets/main_menu.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const MainMenu(),
        automaticallyImplyLeading: false,
      ),
      body: const SingleChildScrollView(
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
    );
  }
}
